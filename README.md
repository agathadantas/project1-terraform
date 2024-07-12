# Projeto Terraform para Infraestrutura na AWS

Este projeto utiliza o Terraform para provisionar e gerenciar a infraestrutura necessária para uma aplicação na AWS. O projeto inclui a configuração de rede, banco de dados, ECS, balanceamento de carga, repositórios de contêineres, e pipelines de CI/CD.

## Estrutura do Projeto

O projeto está estruturado em vários módulos para facilitar a manutenção e a reutilização do código:

- **Networking**: Configuração da VPC, sub-redes e grupos de segurança.
- **Secrets Manager**: Gerenciamento de segredos para a aplicação.
- **Database**: Configuração do banco de dados RDS.
- **ECS**: Configuração do cluster ECS e serviços.
- **Load Balancing**: Configuração do balanceador de carga.
- **ECR**: Configuração do repositório de contêineres.
- **Bucket**: Configuração de buckets S3 e CloudFront.
- **Pipelines**: Configuração de pipelines de CI/CD usando CodePipeline e CodeBuild.

## Pré-requisitos

- [Terraform](https://www.terraform.io/downloads.html) instalado na sua máquina.
- Conta na AWS com permissões apropriadas para criar os recursos.

## Variáveis de Configuração

As variáveis que devem ser configuradas no arquivo `terraform.tfvars` ou passadas como variáveis de ambiente incluem:

- `vpc_cidr`: CIDR block para a VPC.
- `aws_region`: Região da AWS onde os recursos serão provisionados.
- `environment`: Ambiente (ex: dev, prod).
- `db_instance_class`: Classe da instância do banco de dados.
- `use_replica`: Define se uma réplica será usada para o banco de dados.
- `domain`: Domínio para a aplicação.
- `eu-west-1_certificate`: ARN do certificado no `eu-west-1`.
- `us-east-1_certificate`: ARN do certificado no `us-east-1`.
- `source_branch`: Branch do CodeCommit para a pipeline.

## Como Usar

1. Clone o repositório:
   ```bash
   git clone https://github.com/USERNAME/REPOSITORY_NAME.git
   cd REPOSITORY_NAME
