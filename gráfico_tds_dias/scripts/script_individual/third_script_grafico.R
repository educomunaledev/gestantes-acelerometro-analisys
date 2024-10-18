library(tidyverse)
library(lubridate)
library(ggplot2)
library(scales)
library(RColorBrewer)

# Definindo o diretório e lendo a base de dados
setwd("/home/eduardo/tiago/banco_dados")
dados <- read.csv2("MOS2D12160405 (2021-07-10)60sec.csv", stringsAsFactors = FALSE, dec = ",", sep = ",", header = TRUE)

# Removendo espaços nos nomes das colunas
names(dados) <- str_replace_all(names(dados), " ", "")

# Convertendo as colunas Date e Time para um único objeto datetime
dados <- dados %>%
  mutate(DateTime = dmy_hms(paste(Date, Time))) %>%
  mutate(Date = as.Date(DateTime))

# Filtrando os dados para excluir os dias 10, 29 e 30
dados <- dados %>%
  filter(!(day(Date) %in% c(10, 29, 30)))

# Criando rótulos personalizados para as facetas
dados <- dados %>%
  mutate(DateLabel = paste("Dia", format(Date, "%d")))

# Definindo uma paleta de cores que suporta mais de 9 cores
n_colors <- length(unique(dados$Date))
if (n_colors > 9) {
  pastel_colors <- colorRampPalette(brewer.pal(9, "Set1"))(n_colors)
} else {
  pastel_colors <- brewer.pal(n = n_colors, name = "Set1")
}

# Gerando o gráfico com ajuste para mostrar os zeros
grafico <- ggplot(dados, aes(x = DateTime, y = Vector.Magnitude, color = as.factor(Date))) + 
  geom_line(linewidth = 1.2, na.rm = TRUE) +  # Usa linewidth em vez de size
  scale_color_manual(values = pastel_colors) +
  facet_grid(DateLabel ~ ., scales = "free_x", space = "free_y") +
  scale_x_datetime(
    date_labels = "%H:%M",  # Exibe apenas a hora e minutos
    date_breaks = "3 hours",  # Intervalo de rótulos
    expand = c(0, 0)
  ) +
  labs(title = "Vetor de Magnitude ao Longo do Dia",
       x = "Hora",
       y = "Vetor de Magnitude") +
  theme(
    panel.background = element_rect(fill = "#F5F5F5"),  # Fundo cinza bem claro
    panel.grid.major = element_line(color = "gray90"),  # Linhas de grade principais cinza claro
    panel.grid.minor = element_line(color = "gray95"),  # Linhas de grade menores ainda mais claras
    strip.text.y = element_text(angle = 0, size = 12),  # Tamanho do texto das facetas
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),  # Tamanho e rotação dos textos do eixo X
    axis.text.y = element_text(size = 10),  # Tamanho do texto do eixo Y
    axis.title.x = element_text(size = 12),  # Tamanho do título do eixo X
    axis.title.y = element_text(size = 12),  # Tamanho do título do eixo Y
    plot.title = element_text(hjust = 0.5, size = 14),  # Tamanho e alinhamento do título do gráfico
    legend.position = "none",  # Remove a legenda
    panel.spacing = unit(1.5, "lines")  # Ajusta o espaçamento entre facetas
  )

# Exibindo o gráfico
print(grafico)

# Salvando o gráfico em um arquivo
ggsave("grafico_ajustado.png", plot = grafico, width = 14, height = 10, units = "in")
