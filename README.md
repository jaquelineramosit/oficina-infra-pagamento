# Infra Pagamento (SQS + DynamoDB)

Infraestrutura Terraform da parte compartilhada do domínio de pagamento:
as filas SQS e a tabela DynamoDB. A Lambda que as consome (Lambda +
gatilhos) mora num repositório separado,
[`oficina-app-pagamento`](https://github.com/jaquelineramosit/oficina-app-pagamento),
e só referencia esses recursos por variável de ambiente — este repositório
é o único dono da criação deles.

## Filas (`terraform/`)

- `sqs-pagamento-solicitar`
- `sqs-pagamento-recusado`
- `sqs-pagamento-efetuado`

Cada fila tem um workflow de apply próprio em `.github/workflows/`, usando um state remoto separado no S3.

## Tabela DynamoDB (`terraform-dynamodb/`)

- `orders` (chave `order_id`) — estado das orders de pagamento, consumida pela Lambda do `oficina-app-pagamento`.

## CI/CD

- **`terraform-check.yml`** — roda em todo push (exceto direto em `main`) e em PRs para `main`: `terraform fmt -check`, `terraform init -backend=false` e `terraform validate`, para `terraform/` (filas), `terraform-local/` (LocalStack) e `terraform-dynamodb/` (tabela). Não precisa de credenciais AWS.
- **`terraform-apply-sqs-pagamento-*.yml`** e **`terraform-apply-dynamodb-oficina-pagamento.yml`** — disparam no push pra `main` (ou seja, no merge do PR), aplicando de fato na AWS.

## Usando esses recursos no `oficina-app-pagamento`

Depois que os workflows de apply rodarem com sucesso, pegue os outputs:

```bash
terraform -chdir=terraform output
terraform -chdir=terraform-dynamodb output
```

E copie manualmente para as **GitHub Actions Variables** (não Secrets — não
são segredos) do repositório `oficina-app-pagamento`:

| Variable                | De onde vem |
|--------------------------|-------------|
| `SOLICITAR_QUEUE_ARN`     | `terraform -chdir=terraform output` (fila `sqs-pagamento-solicitar`, `queue_arn`) |
| `EFETUADO_QUEUE_URL`      | idem, fila `sqs-pagamento-efetuado`, `queue_url` |
| `RECUSADO_QUEUE_URL`      | idem, fila `sqs-pagamento-recusado`, `queue_url` |
| `ORDERS_TABLE_NAME`       | `terraform -chdir=terraform-dynamodb output` (`table_name`) |

Não existe automação entre os dois repositórios de propósito — os state
files do Terraform ficam desacoplados, então essa cópia é manual sempre que
os recursos mudarem (o que deve ser raro).

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

O `docker-compose.yml` também habilita o serviço `lambda` do LocalStack
(além de `sqs`/`dynamodb`) e monta o socket do Docker — é o que permite ao
[`oficina-app-pagamento`](https://github.com/jaquelineramosit/oficina-app-pagamento)
publicar a Lambda de verdade dentro do LocalStack (não só invocá-la em
processo), disparada automaticamente pela fila `sqs-pagamento-solicitar`.
Veja o README daquele repositório para o passo a passo.

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
