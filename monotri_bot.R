install.packages("googlesheets4")
install.packages("dplyr")
install.packages("stringr")
install.packages("telegram.bot")

library(dplyr)
library(telegram.bot)

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



# FUNCION DE AVISO PARA HACER FACTURA
aviso_factura <- function(bot) {
  
  for (o in 1:nrow(usuarios)) {
    
    user_send <- usuarios[o,]
    
    bot$sendMessage(chat_id = user_send$id,
                    text = paste0("Hola ",user_send$user, " Monotributista! Recordá que tenés que avisarle al Estado para que se haga cargo de tu pago. Ya estamos a 26, es un buen momento para hacer la *factura*"))
    
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


if (Sys.Date() == "2022-10-26") {
  aviso_factura(bot)
}

if (Sys.Date() %in% c("2022-10-18", "2022-11-20", "2022-12-18")) {
  aviso_factura(bot)
}

  