import { execSync, spawnSync } from 'node:child_process'
import { tmpdir } from 'node:os'
// import { join } from 'node:path'
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
export function compileTypst(sourceFile: string, logger: Logger | undefined): { head: string; body: string } {
//   const out = join(tmpdir(), `${randomUUID()}.html`)

  const out = spawnSync('typst', ['compile', '--features', 'html', '--format', 'html', sourceFile, '-'], {
    encoding: 'utf8',
  })

  const lines = out.stderr?.trimEnd()?.split('\n') ?? []

  if (lines.length > 0 ) {
	console.log()
  }

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