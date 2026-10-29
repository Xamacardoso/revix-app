# Design

## Context

O dashboard atualmente mostra cards horizontais e um único resumo selecionado, sem busca textual. Os formulários usam `InputDecoration` direto. O banco está na versão 1, com `maintenance_records.odometer_at_service` definido como obrigatório. A motivação e os contratos estão em `proposal.md` e nos deltas de `specs/`.

## Goals / Non-Goals

**Goals:**
- Manter os cards como acesso rápido e acrescentar busca/localização vertical sem chamadas de rede.
- Permitir km de serviço nulo sem perder registros existentes.
- Manter a tela de detalhes coerente imediatamente após confirmação da atualização do odômetro.
- Padronizar orientação visual, ajuda contextual e tipografia local.

**Non-Goals:**
- Alterar autenticação, sincronização, backup ou o formato de busca remota.
- Tornar outros dados do registro de manutenção opcionais.

## Decisions

- A busca será filtrada em memória sobre os veículos ativos já carregados, comparando apelido, marca, modelo e placa sem diferenciar maiúsculas/minúsculas. Os cards horizontais continuam selecionando o veículo rápido; tocar uma linha vertical seleciona o mesmo veículo e atualiza o resumo.
- Ao confirmar e salvar uma manutenção cujo km supera o atual, o detalhe atualiza seu estado local com o valor persistido antes de mostrar o sucesso. Recusar continua sem gravar manutenção nem alterar o veículo.
- `odometerAtService` passa a ser `int?`. A tela mantém o pré-preenchimento atual, mas a pessoa pode apagar o valor. Registros sem km não entram na comparação que dispara confirmação e aparecem na timeline com “km não informado”.
- A migração v2 recriará `maintenance_records` com a coluna nullable, copiará todas as linhas da v1, substituirá a tabela e recriará seus índices. O formato dos dados existentes permanece preservado.
- Um helper comum de decoração adicionará ícone de campo e ajuda contextual com `Tooltip` aos formulários. A fonte Inter variável será incluída como asset local e usada no tema Material 3, evitando busca/download de fonte em runtime.

## Risks / Trade-offs

- Recriar a tabela exige preservar todos os campos, a chave estrangeira e índices. A migração será exercitada com um banco v1 pré-preenchido e reaberto como v2.
- Uma lista de busca em memória reflete apenas o conjunto já carregado; isso é adequado para o volume local esperado e evita infraestrutura de pesquisa.
- Embutir a fonte aumenta o tamanho do aplicativo, mas garante a mesma tipografia offline nas plataformas.
