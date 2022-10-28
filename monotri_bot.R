#install.packages("googlesheets4")
install.packages("dplyr")
#install.packages("stringr")
install.packages("telegram.bot")
install.packages("glue")
install.packages("lubridates")

library(dplyr)
library(telegram.bot)
library(glue)

token <- Sys.getenv("TOKEN_BOT")
bot <- Bot(token = token)


### SETUP USUARIO TELEGRAM
updates <- bot$getUpdates()

n_users <- length(updates)


if (n_users == 0) {
  
  usuarios <- readRDS("monotribot_usuarios.rds")
  
} else {
  
  users <- data.frame()
  
  for (i in 1:n_users) {
    users <- rbind(users,
                   data.frame(id = updates[[i]]$message$chat$id,
                              user = updates[[i]]$message$chat$first_name))
  }
  
  usuarios <- readRDS("monotribot_usuarios.rds")
  
  usuarios <- rbind(usuarios, users) %>% distinct()
  
  saveRDS(usuarios, "monotribot_usuarios.rds")
  
}

updates <- bot$clean_updates()

hoy <- Sys.Date()


# ### MENSAJE DE BIENVENIDA (APRETANDO /start)
# updater <- Updater(token = token)
# 
# start <- function(bot, update){
#   bot$sendMessage(chat_id = update$message$chat_id,
#                   text = sprintf("Hola! %s!", update$message$from$first_name))
# }
# 
# start_handler <- CommandHandler("start", start)
# 
# 
# ### MENSAJE DE RESPUESTA PARA CUANDO ESCRIBEN AL BOT
# echo <- function(bot, update){
#   bot$sendMessage(chat_id = update$message$chat_id, 
#                   text = "Lo siento, por el momento sólo soy un bot recordatorio")
# }
# 
# echo_handler <- MessageHandler(echo, MessageFilters$text)
# 
# updater <- updater + start_handler + echo_handler
# 
# 
# updater$start_polling()


# FUNCION DE AVISO PARA HACER FACTURA
aviso_factura <- function(bot) {
  
  for (o in 1:nrow(usuarios)) {
    
    user_send <- usuarios[o,]
    
    bot$sendMessage(chat_id = user_send$id,
                    text = paste0("Hola ",user_send$user, " Monotributista! ya estamos a fin de mes. Si tenés que emitir una factura para que te paguen a tiempo, es un buen momento hacerlo!"))
    
    Sys.sleep(0.5)
    
  } 
  
}

# FUNCION DE AVISO PARA HACER FACTURA
aviso_vencimiento <- function(bot) {
  
  for (o in 1:nrow(usuarios)) {
    
    user_send <- usuarios[o,]
    
    bot$sendMessage(chat_id = user_send$id,
                    text = paste0("Hola ",user_send$user, "Si aún no lo pagaste, se te está por vencer el pago mensual del monotriburo, ¡no cuelgues!"))
    
    Sys.sleep(0.5)
    
  } 
  
}


if (lubridate::day(Sys.Date()) %in% c(26:31)) {
  aviso_factura(bot)
}

if (lubridate::day(Sys.Date()) %in% c(17:20)) {
  aviso_vencimiento(bot)
}

  
