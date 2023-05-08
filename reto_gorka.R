rm(list=ls())

# Carga los paquetes necesarios
library(pdftools)
library(tidyverse)
library(readxl)
library(tesseract)

# Define el nombre del archivo PDF
filename <- "C:/Users/Alumno/Desktop/Ainhoa/RETO/RNT_Enero2022.pdf"

# Extrae las tablas de todas las páginas utilizando la biblioteca pdftools
tables <- pdf_convert(filename, dpi = 1200, format = "png")

# Convierte las imágenes PNG a texto utilizando la biblioteca tesseract
# Es necesario haber instalado Tesseract OCR previamente
text <- lapply(tables, tesseract::ocr, engine = tesseract::tesseract())

# Combina todo el texto en un solo vector
text <- unlist(text)

# Separa el texto por saltos de línea y filtra las filas que no contienen datos
text <- strsplit(text, "\n") %>%
  unlist() %>%
  str_trim() %>%
  discard(. == "")

# Separa el texto en tablas utilizando expresiones regulares
# La expresión regular utilizada coincide con las tablas del archivo PDF proporcionado
# Si el formato de las tablas es diferente, es necesario ajustar la expresión regular
regex <- "(\\d{2}-\\d{2}-\\d{4})\\s+(\\d{2}-\\d{2}-\\d{4})\\s+([\\d,\\.]+)\\s+(\\d+)\\s+(\\d+)\\s+(.+)\\s+([\\d,\\.]+)"


# AQUIIII
matches <- str_match(text, regex)

# Convierte las coincidencias a un data frame de R
df <- as.data.frame(matches[, -1])
names(df) <- c("FechasTramoDesde", "FechasTramoHasta", "Importe", "DíasCoti.", "HorasCoti.", "Descripción", "Importe2")

# Elimina la columna Importe2, que no se necesita
df$Importe2 <- NULL

# Limpia los datos
df$Importe <- as.numeric(gsub(",", ".", gsub("\\.", "", df$Importe)))
df$DíasCoti. <- as.integer(gsub("D", "", df$DíasCoti.))
df$HorasCoti. <- as.integer(gsub("H", "", df$HorasCoti.))
df$FechasTramoDesde <- as.Date(df$FechasTramoDesde, format = "%d-%m-%Y")
df$FechasTramoHasta <- as.Date(df$FechasTramoHasta, format = "%d-%m-%Y")

# Exporta la tabla final a Excel
write_xlsx(df, "tabla_final_sinD_ni_H.xlsx")