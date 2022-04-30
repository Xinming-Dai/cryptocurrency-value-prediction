source("ethereum_helpers.r")
library(ggplot2)

returns_ts <- create_data("2021-10-25", "2022-04-26") # add day for returns
returns <- create_data("2021-10-25", "2022-04-26", ts = F)
covars <- colnames(returns_ts)
covars <- covars[! covars %in% c("ETH-USD", "date")]
covars_rf <- colnames(returns)
covars_rf <- covars_rf[! covars_rf %in% c("ETH-USD", "date")]
covars2 <- c("BTC-USD","doge_delta" , "USDT-USD", "GC=F", "BLK", "JPM", "CBRE", 
             "ltc_delta", "SPY", "^DJUSS", "^MID", "sol_delta", "GOOGL")

arima1 <- back_test_arima("ETH-USD", returns_ts, covars, 90, "2022-01-26", "2022-04-26")
bsts1 <- back_test_bsts("ETH-USD", returns_ts, covars, 90, "2022-01-26", "2022-04-26")
rf1 <- back_test_rf("ETH-USD", returns, covars_rf, 90, "2022-01-26", "2022-04-26")

tests <- merge(arima1, bsts1, by = "date", all = T)
tests <- merge(tests, rf1, by = "date", all = T) 
# RENAME COLUMNS APPROPRIATELY

# ADD LEGEND
p <- ggplot(data = tests, aes(x = date)) +
  geom_line(aes(y = true.x), color = "red") +
  geom_line(aes(y = pred.x), color = "blue") +
  geom_line(aes(y = pred.y), color = "green") +
  geom_line(aes(y = pred), color = "black") 
p

mean(arima1$sq_residuals)
mean(bsts1$sq_residuals)
mean(rf1$sq_residuals)

# copy and paste rf for other models, might need to use get_formula and change predict function
# change predictors, change train_pers (currently 90), change rf hyperparameters,
# make chart pretty and compare for final models