import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["input", "messages"]

  connect() {
    const productId = this.element.dataset.productId

    if (!productId) {
      console.warn("❌ Missing data-product-id on product-chat controller element")
      return
    }

    this.channel = consumer.subscriptions.create(
      { channel: "ProductChatChannel", product_id: productId },
      {
        received: (data) => {
          if (this.hasMessagesTarget && data.chunk) {
            const formatted = data.chunk.replace(/\n/g, "<br>")
            this.messagesTarget.insertAdjacentHTML("beforeend", formatted)
            this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
          }
        }
      }
    )
  }

  send(event) {
    event.preventDefault()

    if (!this.hasInputTarget) return

    const message = this.inputTarget.value.trim()
    if (message === "") return

    this.channel.perform("speak", { message })
    this.messagesTarget.insertAdjacentHTML("beforeend", `
      <div class="flex justify-end mb-1">
        <p class="bg-blue-500 text-white px-3 py-2 rounded-lg max-w-xs text-sm">${message}</p>
      </div>
    `)
    this.inputTarget.value = ""
  }
}
