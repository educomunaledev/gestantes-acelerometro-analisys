# Carregando as bibliotecas necessárias
library(ggplot2)   # Para criar gráficos
library(lubridate) # Para manipulação de datas e horas
library(scales)    # Para formatação de escalas
library(stringr)   # Para manipulação de strings

# Definindo o caminho das pastas
pasta <- "/home/eduardo/tiago/banco_dados"  
output_pasta_base <- "/home/eduardo/tiago/grafico_diario/outputs"

# Lista automaticamente todos os arquivos CSV na pasta
file_list <- list.files(path = pasta, pattern = "\\.csv$", full.names = TRUE)

# Função para criar a separação de dia/noite com cores
create_day_night_colors <- function() {
  horas <- seq(from = as.POSIXct("00:00:00", format="%H:%M:%S", tz="UTC"), 
               to = as.POSIXct("23:59:59", format="%H:%M:%S", tz="UTC"), 
               by = "min")
  
  # Definindo os intervalos de cores
  cores <- c(rep("lightgray", 6 * 60),   # Cinza das 00:00 às 06:00
             rep("white", 12 * 60),      # Branco das 06:00 às 18:00
             rep("lightgray", 6 * 60))   # Cinza das 18:00 às 23:59
  
  # Repetir cores para todo o período do dia
  colors <- rep(cores, length.out = length(horas))
  
  data.frame(Hora = horas, y = 1, fill = colors)
}

# Função para converter mês para português
traduzir_mes <- function(data) {
  mes_extenso <- c("janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", 
                   "agosto", "setembro", "outubro", "novembro", "dezembro")
  paste0(day(data), " de ", mes_extenso[month(data)], " de ", year(data))
}

# Loop para processar os arquivos
for (file_name in file_list) {
  
  # Extraindo a data do nome do arquivo
  date_str <- str_extract(basename(file_name), "\\d{4}-\\d{2}-\\d{2}")
  data <- as.Date(date_str, format = "%Y-%m-%d")
  
  # Lendo o arquivo CSV
  dados <- read.csv(file = file_name, dec = ',', stringsAsFactors = FALSE)
  
  # Convertendo data e hora
  dados$DateTime <- as.POSIXct(paste(dados$Date, dados$Time), format = "%d/%m/%Y %H:%M:%S", tz = "UTC")
  dados$Vector.Magnitude <- as.numeric(gsub(",", ".", dados$Vector.Magnitude))
  
  # Extraindo dia e horário
  dados$DiaMes <- as.factor(format(dados$DateTime, "%Y-%m-%d"))
  dados$Hora <- as.POSIXct(format(dados$DateTime, "%H:%M:%S"), format="%H:%M:%S", tz="UTC")
  
  # Cores para o fundo do gráfico
  day_night_colors <- create_day_night_colors()
  
  # Criando pasta específica para o arquivo
  output_pasta <- file.path(output_pasta_base, paste0(gsub("[^a-zA-Z0-9]", "_", str_extract(basename(file_name), "^MOS2D\\d{8}")), "_", date_str))
  dir.create(output_pasta, showWarnings = FALSE, recursive = TRUE)
  
  # Criando gráficos separados para cada dia
  for (dia in unique(dados$DiaMes)) {
    
    dados_dia <- subset(dados, DiaMes == dia)
    
    # Encontrando o valor máximo do eixo y para definir a posição dos símbolos
    max_y <- max(dados_dia$Vector.Magnitude, na.rm = TRUE)
    
    grafico <- ggplot() +
      geom_tile(data = day_night_colors, aes(x = Hora, y = y, fill = fill), height = Inf, alpha = 0.7) +
      geom_line(data = dados_dia, aes(x = Hora, y = Vector.Magnitude, color = Vector.Magnitude), size = 1.2) +
      scale_x_datetime(
        breaks = seq(from = as.POSIXct("00:00:00", format="%H:%M:%S"), to = as.POSIXct("23:59:59", format="%H:%M:%S"), by = "2 hours"),
        labels = date_format("%H:%M"),
        expand = c(0, 0)
      ) +
      scale_y_continuous(expand = expansion(mult = c(0.1, 0.1))) +
      scale_fill_identity(guide = "none") +
      scale_color_gradient(low = "#1F78B4", high = "#E31A1C", guide = "colorbar", name = "Intensidade") +
      annotate("text", x = as.POSIXct("03:00:00", format="%H:%M:%S"), y = max_y * 1.1, label = "\u263E", size = 20, alpha = 0.5, hjust = 0.5) + 
      annotate("text", x = as.POSIXct("12:00:00", format="%H:%M:%S"), y = max_y * 1.1, label = "\u2600", size = 20, alpha = 0.3, hjust = 0.5) + 
      annotate("text", x = as.POSIXct("21:00:00", format="%H:%M:%S"), y = max_y * 1.1, label = "\u263E", size = 20, alpha = 0.5, hjust = 0.5) +
      ggtitle(paste0(gsub("\\.csv$", "", basename(file_name)), " - ", traduzir_mes(data))) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "right",
        plot.title = element_text(hjust = 0.5, size = 14, face = "bold")
      )
    
    # Salvando o gráfico com altura reduzida
    output_file <- file.path(output_pasta, paste0("grafico_", dia, ".png"))
    ggsave(output_file, plot = grafico, width = 12, height = 6, dpi = 300, bg = "transparent")  # Altura reduzida para 6
    
    # Exibindo o gráfico
    print(grafico)
  }
}

