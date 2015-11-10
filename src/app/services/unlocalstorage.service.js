angular.module("mopify.services.unlocalstorage", [])

.factory("UnLocalStorage", function($q, $http, $location, Settings){
    "use strict";

    var mopidyip = Settings.get("mopidyip", $location.host());
    var canupdate = false;
    function UnLocalStorage(){
    }

    UnLocalStorage.prototype.get = function(){
        var deferred = $q.defer();
        $http.get("http://" + mopidyip + ":6686/get_tokens").success(function(data){
          canupdate = data;
          if (!canupdate) {
            deferred.resolve(canupdate);
          } else {
            canupdate.user = JSON.parse(window.atob(canupdate.user));
            console.log(canupdate);
            deferred.resolve(canupdate);
          }
        }).error(function(data){
          canupdate = false;
          deferred.reject(canupdate);
        });
        return deferred.promise;
    };

    UnLocalStorage.prototype.set = function(json){
      var qs = "?";
      for (var key in json) {
        if (json.hasOwnProperty(key)) {
          if (key === "user") {
            var b64 = window.btoa(JSON.stringify(json[key]));
            qs = qs + key + "=" + b64 + "&";
          } else {
            qs = qs + key + "=" + json[key] + "&";
          }
        }
      }
      qs = qs.substring(0, qs.length - 1);
      $http.post("http://" + mopidyip + ":6686/set_tokens" + qs);
    };

    UnLocalStorage.prototype.kill = function(){
      $http.post("http://" + mopidyip + ":6686/kill");
    };
    return new UnLocalStorage();
});
