/// <reference path="tsd.d.ts" />
declare var valueModule: ng.IModule;
declare var serviceModule: ng.IModule;
declare var directiveModule: ng.IModule;
declare var controllerModule: ng.IModule;
declare var appModule: ng.IModule;

declare module powur {
    export interface IUser {
        displayName: string;
    }
    
    export interface ICacheService {
        user: IUser;
        clearAllSession(): void;
        clearAllStorage(): void;
    }
    
    export interface IDataService {
        
    }
}
