/// <reference path='../../typings/references.d.ts' />

module powur {    
    class CacheService implements ICacheService {
        public static ServiceId: string = 'CacheService'; 
        public static $inject: Array<string> = ['$log', '$localStorage', '$sessionStorage'];
        
        public static USER: string = "user";
        
        constructor(private $log: ng.ILogService, private $localStorage: any, private $sessionStorage: any) {
            var self = this;
        }
        
        get user(): IUser {
            return this.getSession(CacheService.USER);
        }
        set user(value: IUser) {
            this.setSession(CacheService.USER, value);
        }
        
        public clearAllSession() {
            delete this.$sessionStorage[CacheService.USER];
        }

        public clearAllStorage() {
            //delete this.$localStorage[aaaa];
        }
        
        private getSession<T>(key: string) {
            return this.$sessionStorage[key];
        }
        
        private setSession(key: string, value: any) {
            this.$sessionStorage[key] = value;
        }

        private getStorage<T>(key: string) {
            return this.$localStorage[key];
        }
        
        private setStorage(key: string, value: any) {
            this.$localStorage[key] = value;
        }        
    }
    
    serviceModule.service(CacheService.ServiceId, CacheService);
}
