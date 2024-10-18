# Carregando as bibliotecas necessárias
library(ggplot2)
library(lubridate)
library(scales)
library(RColorBrewer)
library(stringr)  # Adicionada para manipulação de strings

# Definindo o caminho das pastas
pasta <- "/home/eduardo/tiago/banco_dados"  
output_pasta <- "/home/eduardo/tiago/gráfico_tds_dias/outputs"

# Lista de arquivos CSV
file_list <- list.files(path = pasta, pattern = "\\.csv$", full.names = TRUE)

# Função para criar a separação de dia/noite com cores fixas
create_day_night_colors <- function() {
  horas <- seq(from = as.POSIXct("00:00:00", format="%H:%M:%S", tz="UTC"), 
               to = as.POSIXct("23:59:59", format="%H:%M:%S", tz="UTC"), 
               by = "min")
  
  # Definindo as cores fixas para os períodos do dia
  colors <- c(rep("lightblue", 360),  # Noite (00:00 - 06:00)
              rep("lightyellow", 720),  # Dia (06:00 - 18:00)
              rep("lightblue", 360))  # Noite (18:00 - 23:59)
  
  # Ajustando o comprimento de colors para corresponder ao número de horas
  colors <- rep(colors, length.out = length(horas))
  
  data.frame(
    Hora = horas,
    y = 1,  # Posição fixa no eixo Y para o fundo
    fill = colors
  )
}

# Função para gerar título personalizado
generate_title <- function(file_name) {
  prefix <- substr(file_name, 1, 13)  # Extraindo os 13 primeiros caracteres do nome do arquivo
  date <- str_extract(file_name, "\\(.*?\\)")  # Extraindo a data entre parênteses
  date <- gsub("[()]", "", date)  # Removendo parênteses
  paste("Análise do Vetor De Magnitude Ao Decorrer Dos Dias -", prefix, "-", date)
}

# Função para gerar cores para os dias
generate_day_colors <- function(num_dias) {
  if (num_dias <= 2) {
    # Paleta personalizada para 1 ou 2 dias
    return(c("blue", "green"))
  } else if (num_dias <= 8) {
    # Usando uma paleta de 3 a 8 cores
    return(brewer.pal(n = num_dias, name = "Dark2"))
  } else {
    # Usando uma paleta de 8 cores expandida para mais dias
    return(colorRampPalette(brewer.pal(8, "Dark2"))(num_dias))
  }
}

# Loop para os arquivos
for (caminho_arquivo in file_list) {
  
  file_name <- basename(caminho_arquivo)  # Nome do arquivo sem o caminho
  
  if (file.exists(caminho_arquivo)) {
    
    # Lendo o arquivo CSV
    dados <- read.csv(file = caminho_arquivo, dec = ',', stringsAsFactors = FALSE)
    
    # Convertendo data e hora
    dados$DateTime <- as.POSIXct(paste(dados$Date, dados$Time), format = "%d/%m/%Y %H:%M:%S", tz = "UTC")
    dados$Vector.Magnitude <- as.numeric(gsub(",", ".", dados$Vector.Magnitude))
    
    # Extraindo dia e horário
    dados$DiaMes <- factor(day(dados$DateTime), levels = unique(day(dados$DateTime)))
    dados$Hora <- as.POSIXct(format(dados$DateTime, "%H:%M:%S"), format="%H:%M:%S", tz="UTC")
    
    # Cores para os dias
    num_dias <- length(levels(dados$DiaMes))
    cores_dias <- generate_day_colors(num_dias)
    
    # Cores para o fundo do gráfico
    day_night_colors <- create_day_night_colors()
    
    # Criando o gráfico com cores fixas para os períodos do dia
    grafico <- ggplot() +
      # Adicionando o fundo com cores fixas
      geom_tile(data = day_night_colors, aes(x = Hora, y = y, fill = fill), height = Inf, alpha = 0.7) +
      # Adicionando as linhas do gráfico
      geom_line(data = dados, aes(x = Hora, y = Vector.Magnitude, color = DiaMes, group = DiaMes), size = 1.2) +
      scale_x_datetime(
        breaks = seq(from = as.POSIXct("00:00:00", format="%H:%M:%S"), 
                     to = as.POSIXct("23:59:59", format="%H:%M:%S"), by = "2 hours"),
        labels = date_format("%H:%M"),
        expand = c(0, 0)
      ) +
      scale_y_continuous(expand = expansion(mult = c(0.1, 0.1))) +
      scale_color_manual(values = cores_dias) +
      scale_fill_identity(guide = "none") +
      facet_wrap(~ DiaMes, ncol = 1, scales = "free_y", strip.position = "right") +
      # Adicionando a indicação de sol e lua com menor opacidade
      annotate("text", x = as.POSIXct("03:00:00", format="%H:%M:%S"), y = Inf, label = "\u263E", size = 7, alpha = 0.5, vjust = 1.5, hjust = 0) + # Lua Minguante
      annotate("text", x = as.POSIXct("12:00:00", format="%H:%M:%S"), y = Inf, label = "\u2600", size = 7, alpha = 0.3, vjust = 1.5, hjust = 0) + # Sol com menor opacidade
      annotate("text", x = as.POSIXct("21:00:00", format="%H:%M:%S"), y = Inf, label = "\u263E", size = 7, alpha = 0.5, vjust = 1.5, hjust = 0) + # Lua Minguante
      ggtitle(generate_title(file_name)) + # Adicionando o título
      theme_minimal() +
      theme(
        strip.text.y.right = element_text(angle = 0, hjust = 0.5),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none",
        plot.title = element_text(hjust = 0.5, size = 14, face = "bold") # Ajustando o título
      )
    
    # Criando a pasta de saída para o arquivo, se não existir
    dir.create(output_pasta, showWarnings = FALSE, recursive = TRUE)
    
    # Salvando o gráfico
    output_file <- file.path(output_pasta, paste0("grafico_", gsub("[^a-zA-Z0-9]", "_", file_name), ".png"))
    ggsave(output_file, plot = grafico, width = 12, height = 8, dpi = 300, bg = "transparent")
    
    # Exibindo o gráfico
    print(grafico)
    
  } else {
    warning(paste("Arquivo não encontrado:", caminho_arquivo))
  }
}
