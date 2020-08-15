import { Controller } from "stimulus";
import axios from "axios";
import autocomplete from "autocomplete.js";

export default class extends Controller {
  static targets = ["field"];

  source() {
    const url = this.data.get("url");
    return (query, callback) => {
      axios.get(url, { params: { query } }).then((response) => {
        callback(response.data);
      });
    };
  }

  connect() {
    this.ac = autocomplete(this.fieldTarget, { hint: false }, [
      {
        source: this.source(),
        debounce: 200,
        templates: {
          suggestion: function (suggestion) {
            return autocomplete.escapeHighlightedString(suggestion.value, '<span class="highlighted">', '</span>');
          },
        },
      },
    ]).on("autocomplete:selected", (event, suggestion, dataset, context) => {
      this.ac.autocomplete.setVal(suggestion.value.replace(/<[^>]+>/g, ''));
      this.fieldTarget.classList.remove('is-danger');
    }).on("autocomplete:empty", (event) => {
      this.fieldTarget.classList.add('is-danger');
    });
  }

  update(event) {
    if (this.fieldTarget.value.length == 0) {
      this.fieldTarget.classList.remove('is-danger');
    }
  }
}
