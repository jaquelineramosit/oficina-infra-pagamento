# Infra SQS Pagamento

Infraestrutura Terraform para criar filas AWS SQS do pagamento, cada uma com sua respectiva DLQ.

## Filas

- `sqs-pagamento-solicitar`
- `sqs-pagamento-recusado`
- `sqs-pagamento-efetuado`

Cada fila tem um workflow de apply próprio em `.github/workflows/`, usando um state remoto separado no S3.

## Secrets necessários

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN` (opcional, se usar credencial temporária)
- `AWS_REGION`
- `TF_STATE_BUCKET`

## Proteção da branch main

A proteção contra alterações diretas na `main` precisa ser configurada no GitHub, em `Settings > Branches > Branch protection rules`, ou via GitHub CLI/API. A regra recomendada é exigir pull request antes de merge e exigir o workflow `Terraform Check`.

## Ambiente local (LocalStack)

O deploy real depende de permissões da AWS Academy que hoje bloqueiam a
criação de filas/tabelas (veja o histórico de commits). Para desenvolver e
testar sem depender da AWS, o diretório `terraform-local/` recria as 3
filas (+ DLQs) e a tabela DynamoDB `orders` apontando para uma instância
local do [LocalStack](https://www.localstack.cloud/), via Docker. Esse
diretório é independente do `terraform/` usado pelos workflows de deploy
real — nada aqui afeta o pipeline da AWS.

### Subir o LocalStack

```bash
docker compose up -d
```

Aguarde o container `oficina-localstack` ficar `healthy` (`docker ps`).

### Provisionar os recursos

```bash
terraform -chdir=terraform-local init
terraform -chdir=terraform-local apply
```

Isso cria as filas `sqs-pagamento-solicitar`, `sqs-pagamento-efetuado`,
`sqs-pagamento-recusado` (com suas DLQs) e a tabela DynamoDB `orders`
(chave `order_id`).

### Conferir os recursos criados

```bash
aws --endpoint-url=http://localhost:4566 sqs list-queues
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

(Qualquer valor serve para `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`
localmente — o LocalStack não valida credenciais.)

As URLs das filas e o nome da tabela também ficam disponíveis via
`terraform -chdir=terraform-local output`, para usar como variáveis de
ambiente da Lambda do [`oficina-app-pagamento`](https://github.com/jaquelineramosit/oficina-app-pagamento)
ao testá-la localmente (veja o README daquele repositório).

### Derrubar o ambiente

```bash
terraform -chdir=terraform-local destroy
docker compose down
```
