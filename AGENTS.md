# Contexto do Revix para agentes

## Objetivo do produto

Revix é um aplicativo mobile Flutter para acompanhar manutenção preventiva e corretiva de veículos motorizados. A primeira versão prioriza uso local, offline-first e gerenciamento do histórico por veículo; autenticação real, sincronização e backup em nuvem são etapas futuras.

## Regras de negócio

- Toda operação de dados usa o usuário de compatibilidade `mock_user_default`; mantenha `user_id` no modelo e nas consultas para permitir autenticação futura.
- Veículos podem ser carros, motocicletas, caminhões, vans, ônibus ou outros veículos motorizados.
- Veículos são arquivados, preservando o histórico de manutenção associado. Não remover registros relacionados ao arquivar.
- Quilometragem do serviço é opcional. Se informada e maior que o odômetro atual, pedir confirmação para atualizar o odômetro do veículo; se a pessoa recusar, não salvar o registro nem alterar os dados.
- Atualizar o odômetro atual não exige criar uma manutenção e a tela deve refletir a mudança imediatamente.
- Valores monetários são armazenados em centavos inteiros. O total é derivado da soma das peças e da mão de obra quando ambas forem informadas.
- Manutenções pertencem a um veículo por `vehicle_id`; respeite a separação entre gerenciamento de veículos e manutenção associada a um veículo.

## Arquitetura e dados

- Flutter com persistência SQLite local; as telas acessam repositórios, não o banco diretamente.
- Preserve a separação de domínio, repositório e apresentação entre veículos e manutenções.
- Evolua o banco por migrações incrementais e preserve dados existentes.
- Use UUIDs, timestamps e o `user_id` estático atual nos novos registros.
- Não introduza dependências de rede para funcionalidades que devem funcionar offline.

## Interface

- A garagem tem uma única lista vertical pesquisável de cards grandes e retangulares; cada card abre os detalhes do veículo.
- Evite títulos redundantes: um conteúdo tem um título principal. Seções com conteúdo distinto podem ter subtítulos próprios.
- O fundo padrão é branco; use a paleta centralizada em `lib/core/theme/revix_palette.dart` e mantenha contraste legível.
- Mantenha o app utilizável em telas móveis e na prévia desktop Windows.

## Fluxo de mudança e validação

- Requisitos comportamentais devem ser registrados em OpenSpec (`openspec/`) antes de implementar mudanças de produto.
- Atualize `docs/` quando a mudança alterar decisões, arquitetura ou instruções do produto.
- Use `flutter analyze` para análise estática. Execute `flutter test` quando a tarefa pedir testes ou quando a mudança exigir validação comportamental automatizada.
- Não arquive changes OpenSpec sem solicitação explícita.
