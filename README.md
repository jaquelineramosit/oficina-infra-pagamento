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
