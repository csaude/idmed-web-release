import{u as j,a as F,b as G}from"./QTabs.9968ab83.js";import{l as V,aM as H,aY as C,bq as J,cs as Z,aU as w,ct as A,as as I,ah as D,aV as E,r as L,c as f,w as ee,g as R,aQ as te,h as P,ax as ne,cu as ae,m as _,cv as se,ae as ie,af as re,bo as oe}from"./index.28c7e456.js";import{g as Y,s as z}from"./TouchPan.90ce57a2.js";import{f as ue}from"./position-engine.b3fa6cbd.js";import{u as le}from"./use-render-cache.3aae9b27.js";var xe=V({name:"QTab",props:j,emits:F,setup(t,{slots:s,emit:l}){const{renderTab:c}=G(t,s,l);return()=>c("div")}});function ce(t){const s=[.06,6,50];return typeof t=="string"&&t.length&&t.split(":").forEach((l,c)=>{const r=parseFloat(l);r&&(s[c]=r)}),s}var pe=H({name:"touch-swipe",beforeMount(t,{value:s,arg:l,modifiers:c}){if(c.mouse!==!0&&C.has.touch!==!0)return;const r=c.mouseCapture===!0?"Capture":"",e={handler:s,sensitivity:ce(l),direction:Y(c),noop:J,mouseStart(a){z(a,e)&&Z(a)&&(w(e,"temp",[[document,"mousemove","move",`notPassive${r}`],[document,"mouseup","end","notPassiveCapture"]]),e.start(a,!0))},touchStart(a){if(z(a,e)){const o=a.target;w(e,"temp",[[o,"touchmove","move","notPassiveCapture"],[o,"touchcancel","end","notPassiveCapture"],[o,"touchend","end","notPassiveCapture"]]),e.start(a)}},start(a,o){C.is.firefox===!0&&A(t,!0);const m=I(a);e.event={x:m.left,y:m.top,time:Date.now(),mouse:o===!0,dir:!1}},move(a){if(e.event===void 0)return;if(e.event.dir!==!1){D(a);return}const o=Date.now()-e.event.time;if(o===0)return;const m=I(a),h=m.left-e.event.x,p=Math.abs(h),b=m.top-e.event.y,u=Math.abs(b);if(e.event.mouse!==!0){if(p<e.sensitivity[1]&&u<e.sensitivity[1]){e.end(a);return}}else if(window.getSelection().toString()!==""){e.end(a);return}else if(p<e.sensitivity[2]&&u<e.sensitivity[2])return;const v=p/o,y=u/o;e.direction.vertical===!0&&p<u&&p<100&&y>e.sensitivity[0]&&(e.event.dir=b<0?"up":"down"),e.direction.horizontal===!0&&p>u&&u<100&&v>e.sensitivity[0]&&(e.event.dir=h<0?"left":"right"),e.direction.up===!0&&p<u&&b<0&&p<100&&y>e.sensitivity[0]&&(e.event.dir="up"),e.direction.down===!0&&p<u&&b>0&&p<100&&y>e.sensitivity[0]&&(e.event.dir="down"),e.direction.left===!0&&p>u&&h<0&&u<100&&v>e.sensitivity[0]&&(e.event.dir="left"),e.direction.right===!0&&p>u&&h>0&&u<100&&v>e.sensitivity[0]&&(e.event.dir="right"),e.event.dir!==!1?(D(a),e.event.mouse===!0&&(document.body.classList.add("no-pointer-events--children"),document.body.classList.add("non-selectable"),ue(),e.styleCleanup=T=>{e.styleCleanup=void 0,document.body.classList.remove("non-selectable");const g=()=>{document.body.classList.remove("no-pointer-events--children")};T===!0?setTimeout(g,50):g()}),e.handler({evt:a,touch:e.event.mouse!==!0,mouse:e.event.mouse,direction:e.event.dir,duration:o,distance:{x:p,y:u}})):e.end(a)},end(a){e.event!==void 0&&(E(e,"temp"),C.is.firefox===!0&&A(t,!1),e.styleCleanup!==void 0&&e.styleCleanup(!0),a!==void 0&&e.event.dir!==!1&&D(a),e.event=void 0)}};if(t.__qtouchswipe=e,c.mouse===!0){const a=c.mouseCapture===!0||c.mousecapture===!0?"Capture":"";w(e,"main",[[t,"mousedown","mouseStart",`passive${a}`]])}C.has.touch===!0&&w(e,"main",[[t,"touchstart","touchStart",`passive${c.capture===!0?"Capture":""}`],[t,"touchmove","noop","notPassiveCapture"]])},updated(t,s){const l=t.__qtouchswipe;l!==void 0&&(s.oldValue!==s.value&&(typeof s.value!="function"&&l.end(),l.handler=s.value),l.direction=Y(s.modifiers))},beforeUnmount(t){const s=t.__qtouchswipe;s!==void 0&&(E(s,"main"),E(s,"temp"),C.is.firefox===!0&&A(t,!1),s.styleCleanup!==void 0&&s.styleCleanup(),delete t.__qtouchswipe)}});const de={name:{required:!0},disable:Boolean},K={setup(t,{slots:s}){return()=>P("div",{class:"q-panel scroll",role:"tabpanel"},_(s.default))}},ve={modelValue:{required:!0},animated:Boolean,infinite:Boolean,swipeable:Boolean,vertical:Boolean,transitionPrev:String,transitionNext:String,transitionDuration:{type:[String,Number],default:300},keepAlive:Boolean,keepAliveInclude:[String,Array,RegExp],keepAliveExclude:[String,Array,RegExp],keepAliveMax:Number},fe=["update:modelValue","beforeTransition","transition"];function me(){const{props:t,emit:s,proxy:l}=R(),{getCache:c}=le();let r,e;const a=L(null),o=L(null);function m(n){const i=t.vertical===!0?"up":"left";x((l.$q.lang.rtl===!0?-1:1)*(n.direction===i?1:-1))}const h=f(()=>[[pe,m,void 0,{horizontal:t.vertical!==!0,vertical:t.vertical,mouse:!0}]]),p=f(()=>t.transitionPrev||`slide-${t.vertical===!0?"down":"right"}`),b=f(()=>t.transitionNext||`slide-${t.vertical===!0?"up":"left"}`),u=f(()=>`--q-transition-duration: ${t.transitionDuration}ms`),v=f(()=>typeof t.modelValue=="string"||typeof t.modelValue=="number"?t.modelValue:String(t.modelValue)),y=f(()=>({include:t.keepAliveInclude,exclude:t.keepAliveExclude,max:t.keepAliveMax})),T=f(()=>t.keepAliveInclude!==void 0||t.keepAliveExclude!==void 0);ee(()=>t.modelValue,(n,i)=>{const d=k(n)===!0?S(n):-1;e!==!0&&$(d===-1?0:d<S(i)?-1:1),a.value!==d&&(a.value=d,s("beforeTransition",n,i),te(()=>{s("transition",n,i)}))});function g(){x(1)}function N(){x(-1)}function Q(n){s("update:modelValue",n)}function k(n){return n!=null&&n!==""}function S(n){return r.findIndex(i=>i.props.name===n&&i.props.disable!==""&&i.props.disable!==!0)}function U(){return r.filter(n=>n.props.disable!==""&&n.props.disable!==!0)}function $(n){const i=n!==0&&t.animated===!0&&a.value!==-1?"q-transition--"+(n===-1?p.value:b.value):null;o.value!==i&&(o.value=i)}function x(n,i=a.value){let d=i+n;for(;d!==-1&&d<r.length;){const q=r[d];if(q!==void 0&&q.props.disable!==""&&q.props.disable!==!0){$(n),e=!0,s("update:modelValue",q.props.name),setTimeout(()=>{e=!1});return}d+=n}t.infinite===!0&&r.length!==0&&i!==-1&&i!==r.length&&x(n,n===-1?r.length:-1)}function B(){const n=S(t.modelValue);return a.value!==n&&(a.value=n),!0}function M(){const n=k(t.modelValue)===!0&&B()&&r[a.value];return t.keepAlive===!0?[P(se,y.value,[P(T.value===!0?c(v.value,()=>({...K,name:v.value})):K,{key:v.value,style:u.value},()=>n)])]:[P("div",{class:"q-panel scroll",style:u.value,key:v.value,role:"tabpanel"},[n])]}function X(){if(r.length!==0)return t.animated===!0?[P(ne,{name:o.value},M)]:M()}function O(n){return r=ae(_(n.default,[])).filter(i=>i.props!==null&&i.props.slot===void 0&&k(i.props.name)===!0),r.length}function W(){return r}return Object.assign(l,{next:g,previous:N,goTo:Q}),{panelIndex:a,panelDirectives:h,updatePanelsList:O,updatePanelIndex:B,getPanelContent:X,getEnabledPanels:U,getPanels:W,isValidPanelName:k,keepAliveProps:y,needsUniqueKeepAliveWrapper:T,goToPanelByOffset:x,goToPanel:Q,nextPanel:g,previousPanel:N}}var Ce=V({name:"QTabPanel",props:de,setup(t,{slots:s}){return()=>P("div",{class:"q-tab-panel",role:"tabpanel"},_(s.default))}}),Te=V({name:"QTabPanels",props:{...ve,...ie},emits:fe,setup(t,{slots:s}){const l=R(),c=re(t,l.proxy.$q),{updatePanelsList:r,getPanelContent:e,panelDirectives:a}=me(),o=f(()=>"q-tab-panels q-panel-parent"+(c.value===!0?" q-tab-panels--dark q-dark":""));return()=>(r(s),oe("div",{class:o.value},e(),"pan",t.swipeable,()=>a.value))}});export{xe as Q,Ce as a,Te as b,ve as c,fe as d,me as e,de as u};