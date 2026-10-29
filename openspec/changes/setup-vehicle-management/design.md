# Design

## Context

Não há código de aplicativo nem dados existentes no repositório. `vehicle-management` e `vehicle-maintenance` têm contratos separados em suas specs. A motivação e o escopo estão em `proposal.md`.

## Goals / Non-Goals

**Goals:**
- Manter dados e operações de veículos separados dos registros de manutenção.
- Compor os dados das duas capacidades nas telas que precisam mostrar o veículo e seu histórico.
- Preservar uma base local utilizável offline e pronta para receber uma fonte remota no futuro.

**Non-Goals:**
- Implementar autenticação real, APIs remotas, sincronização ou backup em nuvem.
- Resolver conflitos entre dispositivos nesta entrega.

## Decisions

- **Flutter para o aplicativo mobile.** Atende o alvo mobile com uma única base de código e foi a preferência escolhida.
- **SQLite como banco local relacional.** Veículos e manutenções têm relação clara, consultas cronológicas e integridade referencial. Um armazenamento apenas chave-valor dificultaria essas consultas e regras.
- **Separar as capacidades por responsabilidade.** `vehicle-management` é dona dos dados do veículo, odômetro atual, formulários e ciclo de arquivamento. `vehicle-maintenance` é dona dos registros de manutenção, custos, recomendações, filtros, timeline e resumos de serviço.
- **Relacionar registros por identificador estável do veículo.** Cada manutenção mantém `vehicle_id` e `user_id = mock_user_default`. A tela de detalhes do veículo combina os dados do repositório de veículos com a timeline fornecida pela capacidade de manutenção.
- **Separar repositórios de veículos e de manutenções.** A interface e a lógica de aplicação usam esses limites sem acessar SQLite diretamente. Isso permite introduzir uma fonte remota futuramente sem mover regras de persistência para as telas.
- **Coordenar a confirmação de odômetro acima do atual na operação de criação da manutenção.** Quando a pessoa confirma, atualizar o odômetro do veículo e salvar a manutenção como uma única operação consistente. Quando recusa, não alterar nenhum dos dois.
- **Arquivar veículos com metadado em vez de apagá-los.** A ação preserva as manutenções associadas e permite restauração. O histórico pode continuar vinculado ao mesmo identificador estável.
- **Usar UUIDs, timestamps e migrações versionadas.** Esses metadados preservam a identidade e a evolução do esquema local para uma futura sincronização.
- **Armazenar valores monetários em unidades inteiras da menor fração da moeda.** Isso evita erros de arredondamento de ponto flutuante em somas de peças e mão de obra; a apresentação converte para formato monetário.

## Risks / Trade-offs

- **Perda ou troca do aparelho antes de existir backup →** os dados locais podem ser perdidos; manter backup em nuvem fora do MVP e comunicar que os dados ficam no dispositivo.
- **Metadados preparados para sync sem protocolo de sync →** não garantem resolução de conflitos; definir sincronização e tombstones remotos em uma mudança futura.
- **A operação de manutenção também poder atualizar o veículo →** uma falha parcial poderia deixar os dados inconsistentes; persistir ambas as alterações na mesma transação local.
- **Dependência de SQLite/plug-in nativo →** validar compatibilidade com as versões alvo de Flutter e iOS/Android durante a implementação.

## Migration Plan

Como o projeto não possui aplicativo nem dados existentes, iniciar com esquema local versão 1, com tabelas separadas para veículos e manutenções e vínculo por `vehicle_id`. Toda alteração posterior de esquema deve entrar por migração versionada. Não há migração de dados remotos nesta entrega.
