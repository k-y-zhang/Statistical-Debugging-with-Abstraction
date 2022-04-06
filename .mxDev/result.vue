<template>
  <div>
    <el-button type="primary">
    </el-button>
    <el-input placeholder="请输入内容(不起作用)" v-model="elInput1_props['value']">
    </el-input>
    <el-row :gutter="24" type="flex">
        <el-col>
        </el-col>
    </el-row>
  </div>
</template>
<script>
const childrenProps = {};

export default {
     data() {
          return {
              elInput1_props : childrenProps.elInput1(),
          }
     }
}

childrenProps.elInput1 = function(){
    return {
        "value":"输入框",
    }
};

</script>
<style>
</style>