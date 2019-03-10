FROM rocker/tidyverse:devel

RUN apt-get update

RUN apt-get install -y \ 
    vim

RUN Rscript -e 'upgrade.packages()'

RUN install2.r -e \
    devtools \
    here \
    skimr \
    tidyquant \
    tsibble \
    workflowr

RUN installGithub.r \ 
    braverock/blotter@bc75cf5 \
    braverock/quantstrat@be01b35 \
    hrbrmstr/hrbrthemes@v0.6.0 \
    DavisVaughan/tidyfinance@56917ea

RUN cd /home/rstudio/.rstudio/monitored/user-settings/ \ 
  && mv user-settings user-settings.copy \ 
  && wget https://gist.githubusercontent.com/timtrice/94a679b51388faf99ef7918c7bdaff8d/raw/9a52ffebd1e2e8587918a31ff8e962110b816936/user-settings \ 
  && chown -R rstudio:rstudio user-settings

RUN Rscript -e 'sessionInfo();'
