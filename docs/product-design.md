# Decisões de produto e interface

**Status:** referência do produto atual. Requisitos de comportamento são normatizados pelo OpenSpec.

## Princípios de interface

- Priorizar a leitura rápida no celular: resumo essencial primeiro e ações frequentes acessíveis com uma mão.
- Usar a categoria do veículo nos ícones e nos rótulos para evitar que uma motocicleta pareça um carro.
- Manter as escolhas de tipo explícitas: carro, motocicleta, caminhão, van, ônibus ou outro veículo motorizado.
- Usar uma única lista vertical pesquisável de cards grandes e retangulares; cada card abre os detalhes do veículo correspondente.
- Evitar títulos redundantes: cada tela ou seção apresenta um título principal para o conteúdo, sem repetir o mesmo significado em um cabeçalho adjacente.
- Explicar campos menos óbvios com ícone de ajuda e tooltip, preservando rótulos legíveis e validação junto ao campo.
- Não esconder inconsistências de quilometragem: quando o km do serviço ultrapassar o atual, pedir confirmação antes de atualizar ambos.

## Direção visual atual

- Flutter Material 3 com fundo branco, carvão, roxo, lilás, neutro lavanda e creme de apoio; os tokens e usos estão em [design/color-palette.md](design/color-palette.md).
- Logotipo do Revix na barra superior e no estado vazio da garagem; regras em [design/logo-usage.md](design/logo-usage.md).
- Fonte Inter empacotada localmente para renderização sem rede.
- Ícones Material locais e categorias reconhecíveis por rótulo e ícone.
- Valores monetários exibidos em reais e armazenados em centavos inteiros.

## Fluxos de referência

- **Garagem:** título único “Sua garagem” → busca → lista vertical de cards → detalhes do veículo.
- **Cadastro:** identificação, categoria, marca/modelo e dados do veículo → validações inline → salvar.
- **Manutenção:** título/tipo/data → km opcional e custos → detalhes e próxima revisão → salvar.

## Referências de design

- [Wireframe textual do gerenciamento de veículos](design/vehicle-management-wireframe.md)
- [Convenções para capturas do aplicativo](screenshots/README.md)
