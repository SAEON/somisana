
export default (name) => {
  const colors = d3[`scheme${name}`];
  const n = colors.length;
  const dark = d3.lab(colors[0]).l < 50;;
  const canvas = svg`<svg viewBox="0 0 ${n} 1" style="display:block;width:${n * 33}px;height:33px;margin:0 -14px;cursor:pointer;">${colors.map((c, i) => svg`<rect x=${i} width=1 height=1 fill=${c}>`)}`;
  const label = document.createElement("DIV");
  label.textContent = name;
  label.style.position = "absolute";
  label.style.top = "4px";
  label.style.color = dark ? `#fff` : `#000`;
  canvas.onclick = () => {
    label.textContent = "Copied!";
    navigator.clipboard.writeText(JSON.stringify(colors));
    setTimeout(() => label.textContent = name, 2000);
  };
  return html`${canvas}${label}`;
}