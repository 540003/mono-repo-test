import './assets/main.css'

import { createApp } from 'vue'
import App from './App.vue'
import { greet } from '@acme/shared'
console.log(greet('frontend'))
createApp(App).mount('#app')
