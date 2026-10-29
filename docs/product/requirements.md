# Requisitos do produto

## Propósito

O Revix ajuda a manter o histórico de manutenção preventiva e corretiva de veículos e a consultar rapidamente o que foi feito, quando foi feito e quanto custou.

## Princípios vigentes

- **Mobile-first e offline-first:** o aplicativo funciona e persiste dados localmente sem conexão.
- **Histórico confiável:** registros de manutenção pertencem a um veículo e são preservados quando ele é arquivado.
- **Vários tipos de veículo:** carro, motocicleta, caminhão, van, ônibus e outro veículo motorizado podem ter histórico próprio.
- **Migração futura:** os registros usam `user_id = mock_user_default` até a chegada da autenticação; o identificador já faz parte do modelo local.
- **Evolução segura:** mudanças de formato SQLite são versionadas e migram os registros existentes.

## Capacidades atuais

1. Cadastrar, editar, arquivar e restaurar veículos.
2. Pesquisar veículos ativos e abrir os detalhes do veículo selecionado.
3. Registrar manutenções preventivas, corretivas e revisões.
4. Consultar uma timeline cronológica, filtrar registros e editar um registro existente.
5. Atualizar o odômetro do veículo sem criar uma manutenção.
6. Deixar o odômetro de uma manutenção em branco e registrar os custos em centavos.

## Fora do escopo atual

- Login, contas reais e compartilhamento entre usuários.
- Sincronização, backup ou armazenamento remoto.
- Catálogo externo de marcas/modelos e categorias personalizadas.
- Unidades diferentes de km e campos específicos de cada categoria.

Para critérios detalhados e cenários de aceitação, consulte as especificações em `../../openspec/specs/` e os changes em `../../openspec/changes/`.
