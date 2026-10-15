# LycanLoader

Gerador de código PowerShell para baixar vídeos autorizados com yt-dlp no Windows de 64 bits.

## Uso

1. Cole o link e marque que tem permissão para baixar.
2. Copie o código gerado automaticamente.
3. Cole no PowerShell e pressione Enter, sem precisar de administrador.

O código encontra a pasta Downloads configurada no Windows e cria `LycanLoader` dentro dela. Instala o yt-dlp portátil se faltar, executa `yt-dlp -U`, instala FFmpeg/FFprobe e Deno se faltarem e verifica os executáveis antes de baixar o vídeo. Ferramentas e vídeos ficam na mesma pasta. FFmpeg e Deno existentes nessa pasta são reaproveitados; instalações externas não são alteradas. O Deno fornece o runtime JavaScript usado pelo yt-dlp para YouTube.

Se a instalação ou atualização falhar, o download não começa. A mensagem de erro aparece no PowerShell. O download usa a seleção padrão de qualidade do yt-dlp e não baixa a playlist inteira.

## Privacidade

Página estática, sem envio de links a um servidor do projeto. O código consulta os releases oficiais do yt-dlp, yt-dlp/FFmpeg-Builds e Deno no GitHub e acessa o link informado no computador do usuário. Não utiliza cookies, login ou contorno de DRM.

## Desenvolvimento

Abra `index.html` ou publique os arquivos como site estático. Edite `bootstrap.ps1` e execute `node build.cjs` para atualizar `commands.js`. Execute `node test.cjs` para verificar a geração e a sintaxe. A execução real exige Windows de 64 bits, acesso à internet e um link compatível com yt-dlp.
