# Connor's RSI

$$ \text{BTO} = \text{Adjusted} > \text{SMA (200) } \& \text{ RSI (2)} < 5 $$

$$ \text{STC} = \text{Adjusted} < \text{SMA (200) } \vee \text{ Close} > \text{SMA (5)} $$

## Getting Started

### Prerequisites

Some packages such as `blotter`, `quantstrat`, and `tidyfinance` are not tagged with releases. Therefore, specific commits are used. The strategy is to install packages updated on a specific date, regardless of the version of R released. Other commits or tags may be used but may break the project.

#### Required Packages

##### CRAN

* devtools v2.0.1

* here v0.1

* hrbrmstr/hrbrthemes@v0.6.0

* skimr v1.0.5

* tidyquant v0.5.5

* tsibble v0.7.0

* workflowr v1.2.0

##### Github

* braverock/blotter@bc75cf5

* braverock/quantstrat@be01b35

* DavisVaughan/tidyfinance@56917ea

### Docker

This project contains files to run the project through a Docker container. Dockerfiles exist for the `devel`, `oldrelease`, and `release` versions of R. 

From the project directory via terminal:

```
docker-compose up -d
```

Docker will start a container named "connors_rsi" and open port 8787. To access RStudio server, point your web browser to localhost:8787. The login details:

* User: rstudio
* Password: connors_rsi

The password can be changed in ./docker-compose.yml.

To run a different version of R, change the image tag in ./docker-compose.yml and save:

* image: timtrice/connors_rsi:devel

* image: timtrice/connors_rsi:release

* image: timtrice/connors_rsi:oldrelease

Your local project directory will be mounted to the container so that any changes you make to the project within Docker will remain if the container is destroyed. 

## Built With

* [R 3.5.2](https://www.r-project.org/) - The R Project for Statistical Computing

## Contributing

Please read [Contributing](https://github.com/timtrice/connors_rsi/blob/master/.github/CONTRIBUTING.md) for details on code of conduct.

## Authors

* [Tim Trice](https://github.com/timtrice)

## License

[GNU GENERAL PUBLIC LICENSE](https://github.com/timtrice/connors_rsi/blob/master/LICENSE)
