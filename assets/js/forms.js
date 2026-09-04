async function myForms(){
 const u=await requireAuth(); if(!u)return [];
 const {data,error}=await sb.from('forms').select('*').eq('owner_id',u.id).order('created_at',{ascending:false});
 if(error) throw error; return data||[];
}
async function saveForm(form){
 const u=await requireAuth();
 form.owner_id=u.id;
 const {data,error}=await sb.from('forms').upsert(form).select().single();
 if(error) throw error; return data;
}
async function loadForm(id){
 const {data,error}=await sb.from('forms').select('*').eq('id',id).single();
 if(error) throw error; return data;
}
