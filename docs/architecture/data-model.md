# Arquitetura e modelo de dados

## Camadas

- `domain/`: entidades e enums sem dependência de interface.
- `data/`: contratos de repositório, implementação SQLite e serviços de consistência.
- `presentation/`: telas, formulários, formatos e recursos visuais por feature.
- `core/`: contexto de usuário temporário compartilhado.

As telas dependem dos repositórios e não acessam o SQLite diretamente. Veículos e manutenções são features separadas ligadas pelo `vehicle_id` e pelo mesmo `user_id`.

## Entidades locais

### Vehicle

Contém identificador UUID, `user_id`, nome/apelido, marca, modelo, anos, placa, odômetro atual em km, combustível, categoria, status de arquivamento e timestamps.

Categorias atuais (`vehicle_type`): `CAR`, `MOTORCYCLE`, `TRUCK`, `VAN`, `BUS`, `OTHER`. A ausência do campo em dados antigos é interpretada como `CAR`.

### MaintenanceRecord

Contém identificador UUID, `user_id`, `vehicle_id`, título, tipo, data, km opcional do serviço, custos em centavos, oficina, observações, recomendações e timestamps. Registros são ordenados do mais recente para o mais antigo.

## SQLite

- Versão 1: tabelas de veículos e manutenções com índices e chave estrangeira composta.
- Versão 2: permite `odometer_at_service` nulo, preservando registros e recriando índices.
- Versão 3: adiciona `vehicle_type` com default `CAR`, preservando veículos existentes.
- A versão do esquema é centralizada em `AppDatabase.schemaVersion`; mudanças de formato precisam de migração incremental testada a partir de um banco anterior.

## Preparação para sincronização futura

IDs estáveis, timestamps e `user_id` estão presentes desde o armazenamento local. A sincronização e o backup remoto não fazem parte da implementação atual. Mudanças futuras deverão definir conflitos, exclusão/arquivamento e estratégia offline antes de conectar um serviço remoto.
