library(tidyverse)
library(lubridate)
library(ggplot2)
library(scales)
library(RColorBrewer)

# Definindo o diretório e lendo a base de dados
setwd("/home/eduardo/tiago/banco_dados")
dados <- read.csv2("MOS2D08171310 (2021-06-26)60sec.csv", stringsAsFactors = FALSE, dec = ",", sep = ",", header = TRUE)

# Removendo espaços nos nomes das colunas
names(dados) <- str_replace_all(names(dados), " ", "")

# Convertendo as colunas Date e Time para um único objeto datetime
dados <- dados %>%
  mutate(DateTime = dmy_hms(paste(Date, Time))) %>%
  mutate(Date = as.Date(DateTime))

# Criando rótulos personalizados para as facetas
dados <- dados %>%
  mutate(DateLabel = paste("Dia", format(Date, "%d")))

# Definindo cores pastel
pastel_colors <- RColorBrewer::brewer.pal(n = length(unique(dados$Date)), name = "Pastel1")

# Gerando o gráfico com ajuste para mostrar os zeros
ggplot(dados, aes(x = DateTime, y = Vector.Magnitude, color = as.factor(Date))) + 
  geom_line(size = 1.2, na.rm = FALSE) +  # Certifica-se de incluir valores zero
  scale_color_manual(values = pastel_colors) +
  facet_grid(DateLabel ~ ., scales = "free_x", space = "free_y") +
  scale_x_datetime(date_labels = "%H:%M", date_breaks = "2 hours", expand = c(0, 0)) +
  labs(title = "Vetor de Magnitude ao Longo do Dia",
       x = "Hora",
       y = "Vetor de Magnitude") +
  theme(
    panel.background = element_rect(fill = "#F5F5F5"),  # Fundo cinza bem claro
    panel.grid.major = element_line(color = "gray90"),  # Linhas de grade principais cinza claro
    panel.grid.minor = element_line(color = "gray95"),  # Linhas de grade menores ainda mais claras
    strip.text.y = element_text(angle = 0),
    axis.text.x = element_text(angle = 90, hjust = 1),
    panel.spacing.y = unit(1, "lines"),
    plot.title = element_text(hjust = 0.5),
    legend.position = "none"
  )
