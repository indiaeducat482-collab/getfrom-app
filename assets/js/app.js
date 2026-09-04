const CATS=['All','Business','Education','Booking','Healthcare','Restaurant','Retail','Real Estate','Events','HR','Finance','Fitness'];
const ICONS=['🏢','📚','📅','🏥','🍽️','🛒','🏠','🎉','👥','💰','🏋️'];
const BASE=[
['Business Portal','Business'],['Customer Portal','Business'],['CRM Workspace','Business'],['School Management','Education'],['Coaching Center','Education'],['Appointment Booking','Booking'],
['Clinic Portal','Healthcare'],['Restaurant Ordering','Restaurant'],['Online Store','Retail'],['Property Portal','Real Estate'],['Event Registration','Events'],['Employee Hub','HR'],['Invoice Manager','Finance'],['Fitness Club','Fitness']
];
const TEMPLATES=[];BASE.forEach((x,i)=>['Starter','Professional','Enterprise'].forEach((v,j)=>TEMPLATES.push({id:`${i}-${j}`,name:j?`${x[0]} ${v}`:x[0],category:x[1],icon:ICONS[i%ICONS.length],description:`Editable ${x[1].toLowerCase()} application with pages, forms and data.`})));

const esc=s=>String(s??'').replace(/[&<>"']/g,m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));
const uid=()=>crypto.randomUUID();
async function session(){if(!sb)return null;return (await sb.auth.getSession()).data.session}
async function requireLogin(){let s=await session();if(!s)location='login.html';return s}
function shell(active=''){
 return `<aside class="side"><a class="logo" href="../index.html"><span>F</span>GetFROM</a>
 ${[['workspace.html','🏠 Dashboard'],['templates.html','🎨 Templates'],['ai-create.html','✨ AI Create'],['app-builder.html','🛠️ App Builder'],['form-builder.html','📝 Form Builder'],['submissions.html','📥 Submissions'],['super-admin.html','👑 Super Admin']].map(x=>`<a class="${active==x[0]?'on':''}" href="${x[0]}">${x[1]}</a>`).join('')}
 <a href="#" onclick="logout()">🚪 Logout</a></aside>`;
}
async function logout(){if(sb)await sb.auth.signOut();location='login.html'}
async function getApps(){
 const s=await session(); if(!s)return [];
 let {data,error}=await sb.from('gf_apps').select('*').eq('owner_id',s.user.id).order('created_at',{ascending:false});
 if(error){console.error(error);return []}return data||[];
}
async function saveApp(app){
 const s=await session(); if(!s)throw Error('Login required');
 app.owner_id=s.user.id;
 let {error}=await sb.from('gf_apps').upsert(app);if(error)throw error;return app;
}
function makeApp(t,name,desc){
 return {id:uid(),name:name||t.name,category:t.category,description:desc||t.description,theme:'#6d4aff',published:false,
 config:{pages:[{id:uid(),name:'Home',components:[{id:uid(),type:'heading',value:name||t.name},{id:uid(),type:'text',value:desc||t.description},{id:uid(),type:'button',value:'Get Started'}]},{id:uid(),name:'Contact',components:[{id:uid(),type:'heading',value:'Contact Us'},{id:uid(),type:'form',value:'Contact Form'}]}]}}
}
function publicUrl(app){return `${location.origin}${location.pathname.replace(/\/pages\/[^/]+$/,'')}/pages/public-app.html?id=${app.id}`}