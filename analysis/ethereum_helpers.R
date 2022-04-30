library(tidyquant)
library(zoo)
library(dplyr)
library(bsts)
library(lubridate)
library(ranger)

tickers = c("ETH-USD", "BTC-USD", "DOGE-USD", "USDT-USD", "SOL-USD", "BCH-USD",
            "LTC-USD", # other cryptos
            "UST", "SPY", "UBT", # S%P500 and bonds
            "EURUSD=X", "JPY=X", "GBPUSD=X", # forex
            "GC=F", "CL=F", "NG=F", # gold, oil, natural gas futures
            "^DJUSS", "^MID", # small and mid cap stock ETF's
            "TSM", # Largest chip producer
            "GOOGL", "TSLA", "AMZN", # big tech stocks 
            "NVDA", # Make GPU's used for mining
            "JPM", "BLK", "CBRE", # Financial and real estate
            "DIS" # disney, entertainment sector
)

lvcf <- function(x){
  if(is.na(x[1])){
    x[1] = 0
  }
  for(i in 2:length(x)){
    if(is.na(x[i])){
      x[i] = x[i-1]
    }
  }
  return(x)
}

pc_col <- function(x){
  return(((x - lag(x, 1))/lag(x, 1)) * 100)
}


create_data <- function(start_date, end_date, ticks = tickers, ts = T, lags = 3, difference_cryptos = T){
  prices <- tq_get(ticks,
                   from = start_date,
                   to = end_date,
                   get = "stock.prices")
  prices <- prices %>% dplyr::select(date, symbol, adjusted)
  priceH <- data.frame()
  
  for ( i in ticks){
    df <- prices %>% filter(symbol == i) %>% dplyr::select(date, adjusted)
    colnames(df) <- c("date",i)
    if(nrow(priceH) == 0){
      priceH <- df
    }
    else{
      priceH <- merge(priceH, df, by = "date", all =T)
    }
  }
  # lvcf
  for(i in ticks){
    priceH[,i] <- lvcf(priceH[,i])
  }
  returns <- priceH
  for(i in ticks){
    returns[,i] <- pc_col(returns[,i])
  }
  returns[returns == Inf] <- NA
  returns[is.na(returns)] <- NA
  returns <- na.omit(returns)
  if(difference_cryptos == T){
    returns <- returns %>%
      mutate(doge_delta = `DOGE-USD` - returns$`BTC-USD`,
             sol_delta = `SOL-USD` - returns$`BTC-USD`,
             bch_delta = `BCH-USD` - returns$`BTC-USD`,
             ltc_delta = `LTC-USD` - returns$`BTC-USD`) %>%
      dplyr::select(-`DOGE-USD`, -`SOL-USD`, -`BCH-USD`, -`LTC-USD`)
  }
  if(ts == F){
    returns$weekday <- weekdays(returns$date)
    lag_cols <- colnames(returns)
    lag_cols <- lag_cols[! lag_cols %in% c("date", "weekday")]
    for(i in lag_cols){
      for(l in 1:lags){
        name <- paste0(i,'_lag',l)
        returns[,name] <- dplyr::lag(returns[,i],l)
        returns[,name][is.na(returns[,name])] <- 0
      }
    }
  }
  return(returns)
}

get_formula <- function(target, covs){
  formula <- paste0("`",target, "`", ' ~ ')
  for(i in covs){
    formula <- paste0(formula, "`", i, "`", " + ")
  }
  formula <- substr(formula,1,nchar(formula)-3)
  return(formula)
}

back_test_arima <- function(series, data, covs, train_pers, first_pred, last_pred, order_v = c(3,0,3)){
  preds <- c()
  trues <- c()
  pred_dates <- seq(as.Date(first_pred), as.Date(last_pred), by="day")
  for(i in pred_dates){
    train <- data %>% 
      filter(date >= ymd(as.Date(i)) - days(train_pers + 1),
             date <= ymd(as.Date(i)) - days(1))
    test <- data %>% filter(date == as.Date(i))
    model <- arima(train[,series], order=order_v, xreg = train[,covs])
    pred <- predict(model, newxreg = subset(test, select = covs))
    pred <- as.vector(pred$pred[1])
    true <- test[,series]
    preds <- c(preds, pred)
    trues <- c(trues, true)
  }
  backtest <- data.frame(date = pred_dates, true = trues, pred = preds) %>%
    mutate(residuals = trues - preds,
           sq_residuals = residuals^2)
  return(backtest)
}

back_test_bsts <- function(series, data, covs, train_pers, first_pred, last_pred, n_lags = 3){
  formula <- get_formula(series, covs)
  preds <- c()
  trues <- c()
  pred_dates <- seq(as.Date(first_pred), as.Date(last_pred), by="day")
  for(i in pred_dates){
    train <- data %>% 
      filter(date >= ymd(as.Date(i)) - days(train_pers + 1),
             date <= ymd(as.Date(i)) - days(1))
    test <- data %>% filter(date == as.Date(i))
    ss <- AddLocalLevel(list(), y = train[,series])
    ss <- AddAr(ss,
                train[,series],
                lags = n_lags)
    model <- bsts(formula, state.specification = ss, niter = 1000, 
                                 ping=0, seed=2016, data = train, expected.model.size = 3)
    pred <- predict(model, newdata = subset(test, select = covs))
    pred <- pred$mean
    true <- test[,series]
    preds <- c(preds, pred)
    trues <- c(trues, true)
  }
  
  backtest <- data.frame(date = pred_dates, true = trues, pred = preds) %>%
    mutate(residuals = trues - preds,
           sq_residuals = residuals^2)
  return(backtest)
}

back_test_rf <- function(series, data, covs, train_pers, first_pred, last_pred){
  preds <- c()
  trues <- c()
  pred_dates <- seq(as.Date(first_pred), as.Date(last_pred), by="day")
  for(i in pred_dates){
    train <- data %>% 
      filter(date >= ymd(as.Date(i)) - days(train_pers + 1),
             date <= ymd(as.Date(i)) - days(1))
    test <- data %>% filter(date == as.Date(i))
    model <- ranger(data = train, x = train[,covs], y = train[,series])
    pred <- predict(model, test)$predictions
    true <- test[,series]
    preds <- c(preds, pred)
    trues <- c(trues, true)
  }
  backtest <- data.frame(date = pred_dates, true = trues, pred = preds) %>%
    mutate(residuals = trues - preds,
           sq_residuals = residuals^2)
  return(backtest)
}
