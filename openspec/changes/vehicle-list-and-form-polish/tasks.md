# Tasks

## 1. Quilometragem opcional e migração

- [x] 1.1 Tornar o odômetro do serviço nullable no modelo e no SQLite com migração v2 que preserve os dados v1 e recrie índices; verificar migração/reabertura e manutenção antiga com testes de banco.
- [x] 1.2 Permitir apagar o km pré-preenchido no formulário, salvar `null`, evitar prompt de atualização quando ausente e exibir “km não informado” na timeline; verificar criação, edição e leitura sem km com testes.

## 2. Garagem pesquisável

- [x] 2.1 Manter os cards como “Listagem rápida” e acrescentar lista vertical com busca local por apelido, marca, modelo ou placa e seleção sincronizada; verificar resultados, estado vazio e atualização do resumo com testes de interface.

## 3. Usabilidade dos formulários

- [x] 3.1 Padronizar ícones e tooltips explicativos nos campos de veículo e manutenção, melhorar hierarquia visual e aplicar fonte Inter empacotada no tema; verificar tooltips, formulários e carregamento offline da fonte com testes/análise.

## 4. Atualização imediata do odômetro

- [x] 4.1 Após confirmar e salvar uma manutenção com km maior, atualizar o detalhe no mesmo fluxo; verificar que confirmar mostra o novo km e recusar não altera km nem cria registro com testes.
- [x] 4.2 Executar testes completos e análise estática, corrigir falhas e registrar no README a migração, os campos opcionais e as verificações realizadas.
