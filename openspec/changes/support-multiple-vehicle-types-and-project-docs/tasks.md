# Tasks

## 1. Modelo e migração

- [x] 1.1 Adicionar `VehicleType` com carro, motocicleta, caminhão, van, ônibus e outro; verificar leitura/escrita de tipos e fallback de mapa legado com testes de modelo/repositório.
- [x] 1.2 Criar migração SQLite v3 que adicione `vehicle_type` com default `CAR`, preserve linhas v2 e aceite novos tipos; verificar upgrade v2 para v3 e leitura do tipo com teste de banco.

## 2. Cadastro e apresentação

- [x] 2.1 Incluir seletor de tipo no formulário de veículo, salvar e editar a categoria; verificar seleção, validação e retorno do tipo por teste de widget.
- [x] 2.2 Exibir tipo/ícone apropriado nos cards, lista e detalhes; verificar representação de carro, motocicleta e categorias de trabalho com testes de widget.

## 3. Documentação do projeto

- [x] 3.1 Criar `docs/` com índice e artefatos de produto, design, arquitetura/dados, operação, changelog e convenção de screenshots; verificar estrutura, links internos e consistência com OpenSpec.
- [x] 3.2 Atualizar README com link para a documentação e versão atual do esquema; verificar referências, executar `flutter test`, `flutter analyze` e `openspec validate support-multiple-vehicle-types-and-project-docs`.
