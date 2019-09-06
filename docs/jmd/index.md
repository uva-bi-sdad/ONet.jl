# GitHubAPI.jl

Author/Maintainer: [José Bayoán Santiago Calderón](https://jbsc.netlify.com) ([Nosferican](https://github.com/Nosferican))

This application is developed by the Social and Decision Analytics Division of the [Biocomplexity Institute and Initiative](https://biocomplexity.virginia.edu/), University of Virginia.

[ONet.jl](https://github.com/uva-bi-sdad/ONet.jl) is an application to collect [O*Net](https://www.onetcenter.org/) data.

## Acknowledgment

<p style="text-align: center"><a href="https://services.onetcenter.org/" title="This site incorporates information from O*NET Web Services. Click to learn more."><img src="https://www.onetcenter.org/image/link/onet-in-it.svg" style="width: 130px; height: 60px; border: none" alt="O*NET in-it"></a></p>
<p>This site incorporates information from <a href="https://services.onetcenter.org/">O*NET Web Services</a> by the U.S. Department of Labor, Employment and Training Administration (USDOL/ETA). O*NET&reg; is a trademark of USDOL/ETA.</p>

## Prerequisites

- A container with Julia in the SDAD server
- Superuser access to the [`sdad_data.burning_glass`](http://sdad.policy-analytics.net:8080/?pgsql=postgis_2&db=sdad_data&ns=onet&select=_metadata) database/schema
- Credentials to use the O*NET REST [API](https://services.onetcenter.org/developer/)

!!! note
    While the application is meant for internal use. The code is ISC licensed and may be useful for other people. Do feel free to fork the project / re-use the code for your purposes.
