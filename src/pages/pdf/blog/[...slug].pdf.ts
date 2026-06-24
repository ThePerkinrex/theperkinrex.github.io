import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';
import { spawnSync } from 'node:child_process';
import { TYPST_ARGS } from '../../../lib/typst';
import path from 'node:path';

export async function getStaticPaths() {
  const posts = await getCollection('blog');
  return posts.map(post => ({
    params: { slug: post.id.replace(/\//g, '-') },
    props: { filePath: post.filePath },
  }));
}

export const GET: APIRoute = ({ props }) => {
  const out = spawnSync(
    'typst',
    ['compile', ...TYPST_ARGS, 
     '--format', 'pdf',
     props.filePath!, '-'],
    { encoding: 'buffer' }
  );

  if (out.error) {
    return new Response('Failed to compile PDF', { status: 500 });
  }

  return new Response(out.stdout, {
    headers: { 'Content-Type': 'application/pdf' },
  });
};