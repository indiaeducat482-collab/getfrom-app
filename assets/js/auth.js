async function getUser(){const {data}=await sb.auth.getUser();return data.user}
async function requireAuth(){const u=await getUser();if(!u) location.href='login.html';return u}
async function logout(){await sb.auth.signOut();location.href='index.html'}
async function register(name,email,password){
 const {data,error}=await sb.auth.signUp({email,password,options:{data:{full_name:name}}});
 if(error) throw error;
 return data;
}
async function login(email,password){
 const {data,error}=await sb.auth.signInWithPassword({email,password});
 if(error) throw error;
 return data;
}
