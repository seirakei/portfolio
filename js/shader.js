export const fragment = await fetch("../shader/fragment.glsl").then(x => x.text());
export const vertex = await fetch("../shader/vertex.glsl").then(x => x.text());