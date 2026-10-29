# Paleta de cores

## Tokens de marca

| Token | Cor | Uso principal |
| --- | --- | --- |
| Carvão | `#242038` | Texto principal, ícones fortes e superfícies escuras |
| Roxo | `#725AC1` | Ações primárias, foco e estados selecionados |
| Lilás | `#8D86C9` | Acentos visuais e ícones decorativos |
| Neutro lavanda | `#CAC4CE` | Bordas, divisores e contêineres selecionados com texto carvão |
| Branco | `#FFFFFF` | Fundo principal do aplicativo, cards e campos |
| Creme | `#F7ECE1` | Superfícies secundárias e destaques quentes |

## Regras de aplicação

- Use `RevixPalette` em `lib/core/theme/revix_palette.dart` como fonte dos valores em código; evite repetir hexadecimais nas telas.
- Use o token branco como fundo padrão das telas e das superfícies de leitura.
- Prefira `ColorScheme` em componentes Flutter para ações, texto e estados selecionados.
- Use branco sobre o roxo principal. Sobre lilás, neutro e creme, use texto carvão.
- Reserve o lilás para acentos quando ele não oferecer contraste suficiente para texto pequeno.
- Use bordas ou separação de espaço para distinguir cards brancos do fundo branco.
- Estados semânticos, como erro, podem usar cores de estado do Material, mas não devem substituir os tokens de marca.
- Não carregue cores ou temas por rede; a aparência deve permanecer disponível offline.

## Referência rápida

```text
Carvão       #242038
Roxo         #725AC1
Lilás        #8D86C9
Neutro       #CAC4CE
Branco       #FFFFFF
Creme        #F7ECE1
```
