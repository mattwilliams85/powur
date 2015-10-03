declare module powur.services {
    export interface IUser {
        displayName: string;
    }
    
    export interface ICacheService {
        user: IUser;
        clearAllSession(): void;
        clearAllStorage(): void;
    }
}
