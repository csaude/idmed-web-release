import{bJ as u,df as a,bL as h,Y as g,bM as o,a$ as v,b4 as d}from"./index.28c7e456.js";const s=u(a),n=h[a.entity],{closeLoading:c,showloading:k}=v(),{alertSucess:b,alertError:S}=d(),{isMobile:r,isOnline:i}=g();var p={post(e){return r.value&&!i.value?this.addMobile(e):this.postWeb(e)},get(e){r.value&&!i.value?this.getMobile():this.getWeb(e)},patch(e,t){if(r.value&&!i.value)this.putMobile(t);else return this.patchWeb(e,t)},async delete(e){return r.value&&!i.value?this.deleteMobile(e):this.deleteWeb(e)},postWeb(e){return o().post("stockLevel",e).then(t=>{s.save(t.data)})},getWeb(e){if(e>=0)return o().get("stockLevel?offset="+e+"&max=100").then(t=>{s.save(t.data),e=e+100,t.data.length>0?this.getWeb(e):c()}).catch(t=>{console.log(t)})},getStockLevelByClinicAndDrugWeb(e,t){return o().get("stockLevel/getStockLevelByClinicAndDrug/"+e+"/"+t).then(l=>(c(),l.data))},patchWeb(e,t){return o().patch("stockLevel/"+e,t).then(l=>{s.save(l.data)})},deleteWeb(e){return o().delete("stockLevel/"+e).then(()=>{s.destroy(e)})},addMobile(e){return n.put(JSON.parse(JSON.stringify(e))).then(()=>{s.save(JSON.parse(e))}).catch(t=>{console.log(t)})},putMobile(e){return n.put(JSON.parse(JSON.stringify(e))).then(()=>{s.save(JSON.parse(e))}).catch(t=>{console.log(t)})},getMobile(){return n.toArray().then(e=>{s.save(e)}).catch(e=>{console.log(e)})},deleteMobile(e){return n.put(e).then(()=>{s.destroy(e),b("O Registo foi removido com sucesso")}).catch(t=>{console.log(t)})},addBulkMobile(e){return n.bulkPut(e).then(()=>{s.save(e)}).catch(t=>{console.log(t)})},newInstanceEntity(){return s.getModel().$newInstance()},getAllstockLevels(){return s.get()},isStockLevelExists(e,t){return s.query().where("clinic_id",e).where("drug_id",t).get().length>0},getStockLevel(e,t){return s.query().where("clinic_id",e).where("drug_id",t).first()}};export{p as s};