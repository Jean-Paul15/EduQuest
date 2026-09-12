const fs=require('fs'),path=require('path');
const root='C:/EduQuest',base=path.join(root,'COURS/cours-production/anglais');
const readEnv=file=>fs.existsSync(file)?Object.fromEntries(fs.readFileSync(file,'utf8').split(/\r?\n/).map(l=>l.match(/^([^#=]+)=(.*)$/)).filter(Boolean).map(([,k,v])=>[k,v.replace(/^['"]|['"]$/g,'')])):{};
const env={...readEnv(path.join(root,'.env')),...readEnv(path.join(root,'site/.env'))};
const url=env.SUPABASE_URL||env.NEXT_PUBLIC_SUPABASE_URL,secret=process.env.ENGLISH_PUBLISH_SECRET;
if(!url||!secret) throw new Error('Missing SUPABASE_URL or ENGLISH_PUBLISH_SECRET');
const endpoint=`${url}/functions/v1/publish-english-terminale`;
const catalog=JSON.parse(fs.readFileSync(path.join(base,'catalog.json'),'utf8'));
const loadJson=p=>JSON.parse(fs.readFileSync(p,'utf8'));
(async()=>{
  for(const [index,chapter] of catalog.entries()){
    const dir=path.join(base,chapter.slug);
    const quizzes=fs.readdirSync(dir).filter(name=>/^quiz-\d+.*\.json$/.test(name)).sort().map(name=>loadJson(path.join(dir,name)));
    const payload={
      secret,index,chapter,quizzes,
      coursePdfBase64:fs.readFileSync(path.join(dir,'course-v1.pdf')).toString('base64'),
      exercisePdfBase64:fs.readFileSync(path.join(dir,'exercise-set-v1.pdf')).toString('base64'),
    };
    const res=await fetch(endpoint,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(payload)});
    const body=await res.json();
    if(!res.ok) throw new Error(`${chapter.slug}: ${JSON.stringify(body)}`);
    console.log(`published ${chapter.slug} (${body.quizzes} quizzes)`);
  }
})().catch(err=>{console.error(err);process.exit(1);});
