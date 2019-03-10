FROM rocker/tidyverse:devel

RUN apt-get update

RUN apt-get install -y \ 
    vim

RUN install2.r -e \
    devtools \
    here \
    skimr \
    tidyquant \
    tsibble \
    workflowr

RUN installGithub.r \ 
    braverock/blotter \
    braverock/quantstrat \
    hrbrmstr/hrbrthemes \
    DavisVaughan/tidyfinance

RUN cd /home/rstudio/.rstudio/monitored/user-settings/ \ 
  && mv user-settings user-settings.copy \ 
  && wget https://gist.githubusercontent.com/timtrice/94a679b51388faf99ef7918c7bdaff8d/raw/9a52ffebd1e2e8587918a31ff8e962110b816936/user-settings \ 
  && chown -R rstudio:rstudio user-settings

RUN Rscript -e 'sessionInfo();'
