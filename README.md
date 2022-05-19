

# Infineon’s Secured IoT Connectivity Kit

# For "CLS-Ready" initiative

1. [About](#about)
2. [Getting Started](#getting_started)
   - [Getting the Code from Github](#getting_code)

## <a name="about"></a>About

This repository is for OPTIGA Trust M on "CLS-Ready"platform.

The “Cybersecurity Labeling Scheme” (CLS)[source link: https://www.csa.gov.sg/Programmes/certification-and-labelling-schemes/cybersecurity-labelling-scheme/about-cls] introduced by “CyberSecurity Agency of Singapore” (CSA) aims to raise the security level of consumer devices and make it easier for layman consumers to identify the security level of the devices.

Infineon Technologies, being an industry leader in providing connected secured solutions to the IoT market, aims to provide security solutions and reference implementations that enables customers to meet the security requirements of the CLS.

The objective of the “Secured IOT Connectivity Kit” is to provide guidelines and reference implementation of Security Use Cases to OEMs/ODMs on the integration of OPTIGATM Trust M and PSoC6x for the customers design.

OEMs/ODMs can adopt the guidelines and reference implementations for their security design to implement a robust and secure design to meet the respective requirements of the CLS certification.

This repository contains three folders, one is "linux-optiga-trust-m" which is running on Raspberry Pi, the second one is "usecase-for-cls" which is focusing on the use cases for cybersecurity labelling scheme, the last one is "psoc62-optiga-cls" which is running on psoc62 wifi BT prototyping kits and used as "CLS-Ready"platform to connect to AWS IoT console.

For use cases for Cybersecurity labelling scheme, please refer to README inside "usecase-for-cls"

## <a name="getting_started"></a>Getting Started

### <a name="getting_code"></a>Getting the Code from Github

Getting the initial code from Github with submodules

```console
foo@bar:~$ git clone --recurse-submodules https://github.com/ying-css/infineon-kits-cls.git
```

For building and implementation, please refer to the README files inside the subfolders.