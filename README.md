# project_cloud_terraform - 2023.2

**Por: Caroline Chaim de Lima Carneiro**
## Deploy da infraestrutura

Antes de realizar o deploy, é necessário instalar o Terraform. Para tanto, basta seguir o [tutorial de instalação do Terraform](https://developer.hashicorp.com/terraform/downloads) de acordo com o sistema operacional. Além do Terraform, também é preciso instalar a [CLI da AWS](https://aws.amazon.com/pt/cli/) de acordo com o sistema operacional. 

Com ambas dependências instaladas, deve-se configurar as credencias da AWS para que o Terraform realize todo o gerenciamento por conta própria. Uma das maneiras mais seguras de gerenciar as credenciais de desenvolvimento da AWS, para evitar vazamento das mesmas, é configurar as credenciais como variáveis de ambiente no computador, de forma que elas não são compartilhadas. Utilizando o comando:

    aws configure

- `AWS Access Key ID` e `AWS Secret Access Key ID`: O **ID** e a **chave de acesso** gerados no console da AWS, na aba *"Credenciais de Segurança"*.
- `Default region name`: A região padrão para se implantar serviços e instâncias. Pode ser deixado em branco, mas a região que estará sendo utilizada é a **us-west-2**.
- `Default output format`: O formato de saída padrão das respostas recebidas. Pode ser deixado em braco.

E necessario que voce crie um par de chaves SSH para acesso as instancias EC2. Para fazer isso, execute o comando abaixo e ele criara um arquivo com par de chaves no diretorio diretamente *acima* do diretorio do projeto *clonado* se esse arquivo nao foi criado acima desse diretorio, voce devera localizar-la e colocar no seu path deviduo

    ssh-keygen -t rsa -b 2048 -f ../nome-da-chave

Antes de executar o projeto, é necessário criar manualmente pelo dashboard da aws um bucket no S3 para armazenar o arquivo de estado do Terraform. O nome do bucket deve ser `testebucketcarol`, incicializado com a regiao `us-east-1`



Também é necessário criar um arquivo de variáveis para a sua base de dados. Para isso, crie um arquivo chamado secrets.tfvars no diretório anterior ao do repositório e preencha-o com as seguintes variáveis:
```
db_name     = "megadados"
db_username = "megadados"
db_password = "megadados"
my_ip       = "ip_sua_maquina"
```
**Caso precise achar o ip da sua maquina, escreva o seguinte comendo no terminal:**
```
ipconfig
```
Em seguida, voce pode rodar o seu projeto usando os seguintes comendos
```
terraform init
terraform plan -var-file=../secrets.tfvars -lock=false
terraform apply -var-file=../secrets.tfvars -lock=false

```

No final da execucao, vai ser apresentado um link da aws onde voce pode acessar a aplicacao atraves de qualquer uma das instancias montadas pelo script.
Caso queira ver as operacoes CRUD, basta rodar a aplicacao com /docs no final 

![diagrama de arquitetura](img/arquitetura-cloud.png)


1. Infraestrutura como Código (IaC) com Terraform.
2. Application Load Balancer (ALB).
3. EC2 com Auto Scaling.
4. Banco de Dados RDS.
5. Aplicação.
6. Análise de Custo com a Calculadora AWS.
7. Documentação.

### Detalhamento de modulos

O projeto foi desenvolvido em Terraform, uma ferramenta de desenvolvimento de infraestrutura como código (IaC), que gerencia instâncias e serviços de diversos provedores, como a AWS. O diretório do projeto está estruturado da seguinte forma:

    .
    ├── project/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── .terraform/
    │       ├── providers/
    │       └── modules/
    │           ├── vpc/
    │   └── modules/
    │       ├── alb/
    │       ├── autoScaling/
    │       ├── cloudWatch/
    │       ├── keyPair/
    │       ├── launchTemplate/
    │       ├── rds/
    │       ├── securityGroups/
    │       ├── launch_template/



Aqui estão alguns detalhes técnicos importantes acerca do código Terraform fornecido:

1. **Configuração de Subnets**: O código define duas subnets públicas e duas privadas, cada uma em zonas de disponibilidade diferentes. Isso não apenas distribui a carga e melhora a resiliência, mas também permite a segregação de tráfego entre recursos públicos e privados, como instâncias de banco de dados e servidores web.

1. **Security Groups e Regras**: Os security groups são configurados para diferentes recursos, como instâncias, load balancers e bancos de dados. As regras definidas permitem tráfego específico (por exemplo, HTTP, SSH, MySQL) de/para blocos de endereços IP definidos, garantindo que apenas o tráfego necessário e seguro seja permitido, o que é fundamental para a segurança da rede.

1. **Gerenciamento de Credenciais do Banco de Dados**: O username e password do banco de dados são gerenciados através de variáveis, o que sugere um método seguro e centralizado de gerenciamento de credenciais, essencial para a segurança e manutenção do banco de dados.

1. **Escolha da Imagem Django para o Launch Template**: A AMI selecionada é específica para Django (Bitnami com Linux Debian 11 - x86-64), o que indica uma configuração otimizada e pronta para uso com aplicações Django, garantindo eficiência e estabilidade. Além disso, a imagem escolhida recebe atualizações regulares, sempre garantindo a última versão estável de todos os componentes.

1. **Auto Scaling Group**: A configuração de um grupo de auto scaling para gerenciar a escalabilidade das instâncias EC2 de forma dinâmica, em resposta a mudanças na demanda ou performance. Mais específicamente, esta escalabilidade é dada pela alta utilização de CPU, que é monitorada através de um alarme CloudWatch.

1. **Balanceamento de Carga (ALB)**: Implementação de um Application Load Balancer, que ajuda a distribuir o tráfego de entrada para melhorar a disponibilidade e a robustez da aplicação.

1. **Monitoramento e Alertas com CloudWatch**: A criação de um alarme CloudWatch para monitorar a utilização de CPU e acionar políticas de auto scaling, garantindo uma gestão eficiente dos recursos.

1. **Armazenamento S3**: A utilização de um bucket S3 para armazenamento de objetos, provendo um meio eficaz e seguro para armazenar e acessar dados. Neste caso, o bucket é utilizado para armazenar o estado do Terraform.

Esses componentes, juntos, formam uma infraestrutura robusta e escalável na AWS, ideal para suportar aplicações web modernas com requisitos complexos de rede, segurança e desempenho.



