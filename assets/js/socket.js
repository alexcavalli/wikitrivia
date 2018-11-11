import {Socket} from "phoenix"

const socket = new Socket("/socket", {params: {token: window.userToken}})

export default socket
