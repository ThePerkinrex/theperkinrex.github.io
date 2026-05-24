import { spawnSync } from 'node:child_process'
// import { tmpdir } from 'node:os'
import { dirname } from 'node:path'
// import { randomUUID } from 'node:crypto'
interface Logger {

        /**
         * Logs a message with `info` level.
         */
        info: (msg: string) => void;
        /**
         * Logs a message with `warn` level.
         */
        warn: (msg: string) => void;
        /**
         * Logs a message with `error` level.
         */
        error: (msg: string) => void;
    
}

export const TYPST_ARGS = ['--features', 'html', '--root', 'src']


export function compileTypst(sourceFile: string, logger: Logger | undefined): { head: string; body: string } {
//   const out = join(tmpdir(), `${randomUUID()}.html`)

  const cmd = 'typst'
  const args = ['compile', ...TYPST_ARGS, '--format', 'html', sourceFile, '-'];
  
	console.log()
  logger?.info('Calling ' + cmd + ' ' + JSON.stringify(args))
  
  const out = spawnSync(cmd, args, {
    encoding: 'utf8',
  })

  const lines = out.stderr?.trimEnd()?.split('\n') ?? []


  for (const l of lines) {
	const line = l.trimEnd()
	logger?.warn("[typst] " + line)
  }

  const html = out.stdout

//   const html = Bun.file(out).text() // or readFileSync(out, 'utf8')

  // Extract <head> inner content and <body> inner content separately
  // so the page template can merge <head> tags (styles, fonts) properly
  const headMatch = html.match(/<head[^>]*>([\s\S]*?)<\/head>/i)
  const bodyMatch = html.match(/<body[^>]*>([\s\S]*?)<\/body>/i)

  return {
    head: headMatch?.[1] ?? '',
    body: bodyMatch?.[1] ?? '',
  }
}