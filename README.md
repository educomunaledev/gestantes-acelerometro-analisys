
# Análise de Dados de Acelerômetros para Gestantes

Este repositório contém a análise de dados coletados de acelerômetros utilizados por gestantes. O objetivo é gerar gráficos de série temporal que visualizam a atividade física das gestantes ao longo do tempo, permitindo insights sobre o comportamento de atividade física durante a gestação.

## Estrutura do Repositório

O repositório é organizado da seguinte forma:

- **banco_dados/**: 
  - Esta pasta contém os arquivos de dados em formato `.csv` utilizados na análise. Os dados incluem informações de movimento coletadas por acelerômetros, categorizadas por dias e horários.

- **script/**: 
  - Esta pasta contém os scripts em R utilizados para gerar os gráficos de série temporal. Ela é subdividida em duas pastas principais:
  
  - **gráfico_diario/**: 
    - Contém scripts projetados para gerar gráficos diários de forma independente.
    - O script principal neste diretório cria gráficos em loop. Para cada dia encontrado nos arquivos do banco de dados, é gerada uma nova pasta na saída (`output`), onde cada gráfico correspondente ao dia é armazenado. Por exemplo, se o arquivo 1 contém dados de 10 dias, serão gerados 10 gráficos em uma pasta específica para o arquivo.

  - **gráfico_tds_dias/**: 
    - Contém scripts para gerar gráficos que apresentam todos os dias em um único gráfico.
    - **script_loop.R**: 
      - Este script gera gráficos em loop, considerando todos os dias de cada arquivo. Se o arquivo 1 possui dados de 10 dias, todos os 10 dias estarão representados em um único gráfico, e um gráfico será gerado para cada arquivo presente no banco de dados.
    - **script_individual.R**: 
      - Este script gera gráficos de forma individual, sem ser em loop. O gráfico é gerado apenas na aba de plot do RStudio, mas apresenta todos os dias em um único gráfico, semelhante ao gráfico gerado pelo script em loop.

- **outputs/**:
  - As pastas de output presentes nas pastas `gráfico_diario` e `gráfico_tds_dias` contêm os resultados dos gráficos gerados. Cada pasta de output corresponde ao respectivo script e pode conter diferentes saídas, devido às diferenças nos objetivos de cada script.

## Como Executar os Scripts

Para executar os scripts em R, siga os passos abaixo:

1. **Clone o Repositório**:
   ```bash
   git clone https://github.com/educomunaledev/gestantes-acelerometro-analisys.git
   ```

2. **Instale as Dependências**: Certifique-se de ter o R e o RStudio instalados em sua máquina. Você pode precisar instalar pacotes como `tidyverse`, `lubridate`, entre outros, que são utilizados nos scripts.

3. **Abra o RStudio**: Navegue até o diretório clonado no RStudio.

4. **Execute os Scripts**:
   - Para executar o script de gráficos diários, abra o script dentro da pasta `gráfico_diario` e execute-o.
   - Para os gráficos com todos os dias, utilize os scripts na pasta `gráfico_tds_dias` conforme desejado.

## Exemplos de Gráficos

### Gráfico Diário
![Gráfico 1](imagens/grafico_diario.png)
Este gráfico apresenta uma visualização da atividade física diária das gestantes, destacando a intensidade do movimento ao longo do dia. Emojis indicativos são utilizados para representar diferentes níveis de atividade em relação ao horário, proporcionando uma compreensão intuitiva dos padrões de movimento. 

### Gráfico de Todos os Dias 
![Gráfico 2](imagens/grafico_tds_dias1.png)
![Gráfico 3](imagens/grafico_tds_dias2.png)
Esses gráficos mostram a evolução da atividade física ao longo de múltiplos dias, permitindo uma análise comparativa das tendências de movimento. Cada gráfico reúne dados de vários dias em uma única visualização, facilitando a identificação de padrões e variações na atividade física das gestantes durante o período analisado. A estrutura dos gráficos oferece insights valiosos sobre a consistência e a intensidade da atividade ao longo do tempo.

## Contribuições

Os dados para este estudo foram provenientes de coleta por formulário e por acelerômetros acoplados a um relógio, utilizados pelas gestantes participantes do projeto. Todo o processo de coleta foi realizado pelo Laboratório LAB C3 da Faculdade de Medicina de Ribeirão Preto, com o devido consentimento das participantes, que assinaram um termo de sigilo e autorização. Os dados estão em formato planilhas .CSV. Este projeto foi desenvolvido por Eduardo Comunale.  

## Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

## Contato

Para perguntas ou comentários, entre em contato:
- **Nome**: Eduardo Comunale
- **Email**: edutristaocomunale@gmail.com

