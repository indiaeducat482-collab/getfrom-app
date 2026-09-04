let fields=[];
const types={text:'Short Text',email:'Email',phone:'Phone',number:'Number',textarea:'Long Text',date:'Date',select:'Dropdown',radio:'Radio',checkbox:'Checkbox',file:'File Upload'};
function preview(f){return f.type==='textarea'?'<textarea placeholder="Customer answer"></textarea>':`<input placeholder="Customer answer">`}
function renderFields(){document.querySelector('#canvas').innerHTML=fields.length?fields.map((f,i)=>`<div class="form-field"><b>${esc(f.label)}</b> <span class="badge">${types[f.type]}</span><button class="btn outline" style="float:right" onclick="removeField(${i})">Remove</button><br>${preview(f)}</div>`).join(''):'<div class="empty">Add fields from the left.</div>'}
function addField(t){fields.push({id:crypto.randomUUID(),type:t,label:types[t]});renderFields()}
function removeField(i){fields.splice(i,1);renderFields()}
async function initBuilder(){
 const u=await requireAuth();if(!u)return;
 const id=new URLSearchParams(location.search).get('id');let old=null;
 if(id){try{old=await loadForm(id);fields=old.fields||[]}catch(e){alert(e.message)}}
 layout('form-builder.html',`<div class="toolbar"><div><h1>Form Builder</h1><p class="muted">Build your GetFROM form</p></div><div><button class="btn outline" onclick="saveCurrent(false)">Save Draft</button> <button class="btn" onclick="saveCurrent(true)">Publish</button></div></div><div class="builder"><div class="panel"><h3>Fields</h3>${Object.entries(types).map(([k,v])=>`<button class="field-btn btn" onclick="addField('${k}')">+ ${v}</button>`).join('')}</div><div class="panel canvas"><input id="title" value="${esc(old?.title||'')}" placeholder="Form Title"><textarea id="desc" placeholder="Description">${esc(old?.description||'')}</textarea><div id="canvas"></div></div><div class="panel"><h3>Public Form</h3><p class="muted">Publish to make your form available with a public URL.</p></div></div>`);renderFields();window.editId=id;
}
async function saveCurrent(published){
 try{
 const form={id:window.editId||crypto.randomUUID(),title:document.querySelector('#title').value||'Untitled Form',description:document.querySelector('#desc').value,fields,published};
 await saveForm(form);alert(published?'Form published successfully!':'Form saved successfully!');location.href='forms.html';
 }catch(e){alert(e.message)}
}
