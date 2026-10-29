# Tasks

## 1. App e persistência local

- [x] 1.1 Criar o esqueleto Flutter com alvos Android e iOS, confirmar os arquivos das duas plataformas e iniciar o app no alvo disponível neste ambiente; a execução mobile ficará acompanhada pela tarefa 4.3.
- [x] 1.2 Adicionar SQLite e migrações versionadas com tabelas separadas para veículos e manutenções; confirmar esquema, vínculo por `vehicle_id` e persistência em testes de banco.
- [x] 1.3 Implementar repositórios separados para veículos e manutenções com UUIDs, timestamps e `mock_user_default`; cobrir cada repositório com testes.
- [x] 1.4 Documentar como executar o app e como funciona o armazenamento local; confirmar que as instruções correspondem ao projeto.

## 2. Capacidade vehicle-management

- [x] 2.1 Implementar formulário de veículo com validação de obrigatórios, seleção de combustível e máscara de placa; verificar formatos antigo e Mercosul e campos inválidos com testes.
- [x] 2.2 Implementar dashboard com cards de veículos ativos e cadastro; verificar estados vazio e preenchido com testes de interface.
- [x] 2.3 Implementar detalhes, edição e atualização rápida do odômetro sem criar manutenção; verificar persistência e ausência de novo registro com testes.
- [x] 2.4 Implementar área de arquivados e restauração sem apagar dados vinculados; verificar que arquivar oculta o veículo e restaurar o retorna com testes.

## 3. Capacidade vehicle-maintenance

- [x] 3.1 Implementar criação e edição de manutenção com defaults de data e odômetro e campos de tipo, custo, prestador, notas e recomendações; verificar formulário e persistência com testes.
- [x] 3.2 Implementar validação do odômetro acima do atual e coordenação com veículo; verificar que confirmar atualiza veículo e salva manutenção atomicamente e que recusar não altera nenhum dos dois.
- [x] 3.3 Implementar cálculo e entrada direta de custos; verificar soma de peças e mão de obra e valor total informado com testes.
- [x] 3.4 Implementar timeline reversa, filtros e resumo da manutenção do veículo selecionado; verificar tipos, ordenação, filtros e resumo com testes.

## 4. Composição e comportamento offline

- [x] 4.1 Compor dados do veículo e timeline de manutenção nos detalhes, mantendo operações nas capacidades correspondentes; verificar navegação e vínculo do histórico com testes de integração.
- [x] 4.2 Confirmar consulta e gravação sem rede e persistência após reiniciar o app no alvo disponível neste ambiente; registrar os resultados na documentação do projeto.
- [ ] 4.3 Quando a instalação Android estiver autorizada e houver ambiente macOS/Xcode para iOS, iniciar e verificar os fluxos offline nos dois alvos; registrar os resultados na documentação do projeto.
