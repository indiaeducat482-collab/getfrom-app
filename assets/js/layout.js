function esc(s){return String(s||'').replace(/[&<>"']/g,m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]))}
function layout(active,content){
 const menu=[['dashboard.html','🏠 Dashboard'],['ai-create.html','✨ AI Create'],['forms.html','📄 My Forms'],['form-builder.html','🛠️ Form Builder'],['apps.html','📱 Apps'],['tables.html','📊 Tables'],['workflows.html','🔄 Workflows'],['reports.html','📈 Reports'],['templates.html','🎨 Templates'],['settings.html','⚙️ Settings']];
 document.body.innerHTML=`<div class="app"><aside class="sidebar"><img src="assets/images/getfrom-logo.svg"><div class="menu">${menu.map(x=>`<a class="${active===x[0]?'active':''}" href="${x[0]}">${x[1]}</a>`).join('')}<a href="#" onclick="logout()">🚪 Logout</a></div></aside><main class="main">${content}</main></div>`;
}
