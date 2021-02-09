<template>
  <div>
    <template v-if="error">
      <h2>An error has occured and this program can not continue.</h2>
      Additional information: {{data.error}}<br>
      <i>Please try again. If the problem persists contact your system administrator for assistance.</i>
      <vui-button :params="{action:'PRG_closefile'}">Restart program</vui-button>
    </template>
    <template v-else>
      <template v-if="filename">
        <h2>Viewing file {{filename}}</h2>
        <div class="item">
          <vui-button :params="{action:'PRG_closefile'}">CLOSE</vui-button>
          <vui-button :params="{action:'PRG_edit'}">EDIT</vui-button>
          <vui-button :params="{action:'PRG_printfile'}">PRINT</vui-button>
        </div><hr>
        {{filedata}}
      </template>
      <template v-else>
        <h2>Available files (local):</h2>
        <table class="table border">
          <tr class="header border">
            <th>File name</th>
            <th>File type</th>
            <th>File size (GQ)</th>
            <th>Operations</th>
          </tr>
          <tr v-for="data in files" :key="data.files">
            <td>{{name}}</td>
            <td>.{{type}}</td>
            <td>{{size}}GQ</td>
            <td>
              <vui-button :params="{action: 'PRG_openfile'}">VIEW</vui-button>
              <vui-button :disabled="value.undeletable" ::params="{action: 'PRG_deletefile'}">DELETE</vui-button>
              <vui-button :disabled="value.undeletable" ::params="{action: 'PRG_rename'}">RENAME</vui-button>
              <vui-button :disabled="value.undeletable" ::params="{action: 'PRG_clone'}">CLONE</vui-button>
              <div v-if="!value.encrypted">
                <vui-button :disabled="value.undeletable" ::params="{action: 'PRG_encypt'}">ENCRYPT</vui-button>
              </div>
              <div v-else>
                <vui-button :disabled="value.undeletable" ::params="{action: 'PRG_decrypt'}">DECYPT</vui-button>
              </div>
              <div v-if="data.usbconnected == 1">
                <vui-button :disabled="value.undeletable" ::params="{action: 'PRG_copytousb'}">EXPORT</vui-button>
              </div>
            </td>
          </tr>
        </table>
        <template v-if="data.usbconnected">
          <h2>Available files (portable device):</h2>
          <table class="table border">
            <tr class="header border">
              <th>File name</th>
              <th>File type</th>
              <th>File size (GQ)</th>
              <th>Operations</th>
            </tr>
            <tr v-for="data in usbfiles" :key="data.usbfiles">
              <td>{{value.name}}</td>
              <td>.{{value.type}}</td>
              <td>{{value.size}}GQ</td>
              <td>
                <vui-button :disabled="value.undeletable" ::params="{action: 'PRG_usbdeletefile'}">DELETE</vui-button>
                <div v-if="data.usbconnected">
                  <vui-button :disabled="value.undeletable" ::params="{action: 'PRG_copyfromusb'}">IMPORT</vui-button>
                </div>
              </td>
            </tr>
          </table>
        </template>
        <vui-button :params="{action: 'PRG_newtextfile'}">NEW DATA FILE</vui-button>
        <vui-button :params="{action: 'PRG_templateprint'}">NEW TEMPLATE FILE</vui-button>
      </template>
    </template>
  </div></template>
</template>

<script>
export default {
  data() {
    return this.$root.$data.state
  }
}
</script>