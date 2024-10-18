library(tidyverse)
library(lubridate)
library(ggplot2)
library(scales)
library(RColorBrewer)

setwd("/home/eduardo/tiago/banco_dados")

# Lista de arquivos CSV e os filtros correspondentes
arquivos <- c("MOS2D08171310 (2021-06-26)60sec.csv", 
              "MOS2D08171311 (2021-06-24)60sec.csv", 
              "MOS2D12160405 (2021-07-10)60sec.csv", 
              "MOS2D12160405 (2021-07-28)60sec.csv", 
              "MOS2D12160405 (2021-08-08)60sec.csv")

filtros <- list(
  NULL,                      # Arquivo 1: sem filtros
  NULL,                      # Arquivo 2: sem filtros
  c(10, 29, 30),             # Arquivo 3: filtrar dias 10, 29 e 30
  c(12, 13, 14, 15, 25, 26, 27, 28),  # Arquivo 4: filtrar dias 12, 13, 14, 15, 25, 26, 27, 28
  c(7, 8)                    # Arquivo 5: filtrar dias 07 e 08
)

# Diretório onde os gráficos serão salvos
output_dir <- "/home/eduardo/tiago/loop_graficos"

# Verificando se o diretório existe, se não, cria
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# Loop sobre a lista de arquivos
for (i in seq_along(arquivos)) {
  arquivo <- arquivos[i]
  filtro <- filtros[[i]]
  
  # Lendo o arquivo CSV
  dados <- read.csv2(arquivo, stringsAsFactors = FALSE, dec = ",", sep = ",", header = TRUE)
  
  # Verificando se há dados
  if (nrow(dados) == 0) {
    message(paste("O arquivo", arquivo, "não contém dados."))
    next
  }
  
  # Removendo espaços nos nomes das colunas
  names(dados) <- str_replace_all(names(dados), " ", "")
  
  # Convertendo as colunas Date e Time para um único objeto datetime
  dados <- dados %>%
    mutate(DateTime = dmy_hms(paste(Date, Time))) %>%
    mutate(Date = as.Date(DateTime))
  
  # Aplicando o filtro específico para o arquivo atual
  if (!is.null(filtro)) {
    dados <- dados %>%
      filter(!(day(Date) %in% filtro))
  }
  
  # Criando rótulos personalizados para as facetas
  dados <- dados %>%
    mutate(DateLabel = paste("Dia", format(Date, "%d")))
  
  # Verificando se há dados após o filtro
  if (nrow(dados) == 0) {
    message(paste("O arquivo", arquivo, "não contém dados após o filtro."))
    next
  }
  
  # Definindo uma paleta de cores que suporta mais de 9 cores
  n_colors <- length(unique(dados$Date))
  if (n_colors > 9) {
    pastel_colors <- colorRampPalette(brewer.pal(9, "Set1"))(n_colors)
  } else {
    pastel_colors <- brewer.pal(n = n_colors, name = "Set1")
  }
  
  # Gerando o gráfico
  p <- ggplot(dados, aes(x = DateTime, y = Vector.Magnitude, color = as.factor(Date))) + 
    geom_line(linewidth = 1.2) + 
    scale_color_manual(values = pastel_colors) +
    facet_grid(DateLabel ~ ., scales = "free_x", space = "free_y") +
    scale_x_datetime(date_labels = "%H:%M", date_breaks = "3 hours", expand = c(0, 0)) +
    labs(title = "Vetor de Magnitude ao Longo do Dia",
         x = "Hora",
         y = "Vetor de Magnitude") +
    theme(
      panel.background = element_rect(fill = "#F5F5F5"),
      panel.grid.major = element_line(color = "gray90"),
      panel.grid.minor = element_line(color = "gray95"),
      strip.text.y = element_text(angle = 0),
      axis.text.x = element_text(angle = 45, hjust = 1),
      axis.text.y = element_text(size = 10),
      axis.title.x = element_text(size = 12),
      axis.title.y = element_text(size = 12),
      plot.title = element_text(hjust = 0.5, size = 14),
      legend.position = "none",
      panel.spacing = unit(1, "lines")
    )
  
  # Definindo o caminho completo e o nome do arquivo para salvar
  nome_arquivo <- file.path(output_dir, paste0(tools::file_path_sans_ext(basename(arquivo)), ".png"))
  
  # Salvando o gráfico
  ggsave(nome_arquivo, plot = p, width = 12, height = 8, dpi = 300)
}
